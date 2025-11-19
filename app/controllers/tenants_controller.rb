class TenantsController < ApplicationController
  before_action :set_tenant, only: [:edit, :update, :change]

  # GET /tenants/:id/edit
  def edit
    @tenant.build_payment if @tenant.payment.blank? && @tenant.plan == 'premium'
  end

  # PATCH /tenants/:id
  def update
    Tenant.transaction do
      if @tenant.update(tenant_params)
        if @tenant.plan == 'premium' && @tenant.payment.blank? && payment_params.present?
          @payment = Payment.new(
            email: tenant_params[:email],
            token: payment_params[:token],
            tenant: @tenant
          )

          begin
            @payment.process_payment
            @payment.save!
          rescue StandardError => e
            flash[:error] = e.message
            @tenant.update(plan: 'free')
            redirect_to edit_tenant_path(@tenant) and return
          end
        end

        redirect_to edit_tenant_path(@tenant), notice: "Plan was successfully updated."
      else
        flash.now[:alert] = "Failed to update plan."
        render :edit
      end
    end
  end

  # GET /tenants/:id/change
  def change
    Tenant.set_current_tenant(@tenant)
    session[:tenant_id] = @tenant.id
    redirect_to home_index_path, notice: "Switched to organization #{@tenant.name}"
  end

  private

  def set_tenant
    @tenant = Tenant.find_by(id: Tenant.current_tenant_id)
    redirect_to root_path, alert: "Tenant not found" unless @tenant
  end

  def tenant_params
    params.require(:tenant).permit(:name, :plan, :email)
  end

  def payment_params
    params.fetch(:payment, {}).permit(:token)
  end
end