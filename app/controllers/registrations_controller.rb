class RegistrationsController < Devise::RegistrationsController
  def create
    user_attrs   = params.require(:user).permit(:email, :password, :password_confirmation)
    tenant_attrs = params.require(:tenant).permit(:name, :plan)
    payment_attrs = params.fetch(:payment, {}).permit(:card_number, :card_cvv, :card_expires_month, :card_expires_year, :token)
    payment_attrs = {} if tenant_attrs[:plan] == 'free'

    user_attrs[:is_admin] = true
    sign_out(:user) if user_signed_in?

    build_resource(user_attrs)

    saved = false
    Tenant.transaction do
      # Build tenant and associate with user as owner
      @tenant = Tenant.new(tenant_attrs)
      @tenant.owner = resource

      unless @tenant.save
        flash[:error] = @tenant.errors.full_messages.join(", ")
        raise ActiveRecord::Rollback
      end

      # Assign tenant to the user
      resource.tenant = @tenant

      # Generate random password if not provided
      if resource.password.blank?
        generated_password = Devise.friendly_token.first(12)
        resource.password = generated_password
        resource.password_confirmation = generated_password
      end

      unless resource.save
        flash[:error] = resource.errors.full_messages.join(", ")
        raise ActiveRecord::Rollback
      end

      # Send password reset email so user can set their password
      resource.send_reset_password_instructions

      # Premium plan payment
      if @tenant.plan == "premium" && payment_attrs.present?
        @payment = @tenant.build_payment(payment_attrs)
        unless @payment.valid?
          flash[:error] = @payment.errors.full_messages.join(", ")
          raise ActiveRecord::Rollback
        end

        begin
          @payment.process_payment
          @payment.save!
        rescue => e
          flash[:error] = e.message
          raise ActiveRecord::Rollback
        end
      end

      saved = true
    end

    if saved
  # Sign in if user is already confirmed
  if resource.confirmed?
    sign_in(:user, resource)
    notice_message = "Signup successful!"
  else
    notice_message = "Please check your email to confirm your account."
  end

   redirect_to root_path, notice: notice_message
  else
   render :new
  end
 end
end