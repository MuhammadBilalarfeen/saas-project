class TenantsController < ApplicationController
  before_action :set_tenant, only: [:edit, :update, :change]

  # GET /tenants/:id/edit
  def edit
    # Build payment object if premium plan and none exists
    @tenant.build_payment if @tenant.payment.blank? && @tenant.plan == 'premium'
  end

  # PATCH /tenants/:id
  def update
    Tenant.transaction do
      if @tenant.update(tenant_params)
        # Only handle payment if tenant is premium
        if @tenant.plan == 'premium' && tenant_params[:payment_attributes].present?
          # Assign payment attributes
          if @tenant.payment.present?
            # Update existing payment
            unless @tenant.payment.update(tenant_params[:payment_attributes])
              flash[:error] = @tenant.payment.errors.full_messages.join(", ")
              raise ActiveRecord::Rollback
            end
          else
            # Create new payment
            @payment = @tenant.build_payment(tenant_params[:payment_attributes])
            unless @payment.valid?
              flash[:error] = @payment.errors.full_messages.join(", ")
              raise ActiveRecord::Rollback
            end

            # Process Stripe payment
            begin
              @payment.process_payment if @payment.respond_to?(:process_payment)
              @payment.save!
            rescue StandardError => e
              flash[:error] = "Payment failed: #{e.message}"
              raise ActiveRecord::Rollback
            end
          end
        end

        redirect_to edit_tenant_path(@tenant), notice: "Plan was successfully updated."
      else
        flash.now[:alert] = "Failed to update plan: " + @tenant.errors.full_messages.join(", ")
        render :edit
      end
    end
  end

  # GET /tenants/:id/change
  def change
    @tenant = Tenant.find(params[:id])
    session[:tenant_id] = @tenant.id
    redirect_to root_path, notice: "Switched to organization #{@tenant.name}"
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
    redirect_to root_path, alert: "Tenant not found" unless @tenant
  end

  def tenant_params
    params.require(:tenant).permit(
      :name, :plan,
      payment_attributes: [:id, :card_number, :card_cvv, :card_expires_month, :card_expires_year, :token]
    )
  end
end