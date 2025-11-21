class MembersController < ApplicationController
  before_action :load_tenant

  def index
    @members = Member.all
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)

    ActiveRecord::Base.transaction do
      @member.save!

      # Find or create Devise user by email
      user = User.find_by(email: @member.email)
      unless user
        temp_password = Devise.friendly_token.first(12)
        user = User.create!(
          email: @member.email,
          password: temp_password,
          password_confirmation: temp_password,
          confirmed_at: nil
        )
      end

      # Ensure we use a persisted Tenant object
      persisted_tenant = Tenant.find(@tenant.id)

      # Associate user to tenant
      user.update!(tenant: persisted_tenant)

      # Send Devise instructions
      user.send_reset_password_instructions
      user.send_confirmation_instructions unless user.confirmed?
    end

    redirect_to members_path, notice: "Member invited/created."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(", ")
    render :new, status: :unprocessable_entity
  end

  private

  def load_tenant
    # Always reload persisted tenant to avoid AssociationTypeMismatch
    @tenant = if Tenant.current_tenant
                Tenant.find(Tenant.current_tenant.id)
              else
                Tenant.find_by(id: session[:tenant_id])
              end
  end

  def member_params
    params.require(:member).permit(:first_name, :last_name, :email)
  end
end