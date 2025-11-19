class RegistrationsController < Devise::RegistrationsController

  def create
    tenant_params  = params.require(:tenant).permit(:name, :plan)
    user_params    = params.require(:user).permit(:email, :password, :password_confirmation)
    payment_params = params[:payment] || {}
    user_params    = params.merge({is_admin: true})

    sign_out(:user) if user_signed_in?

    # Optional: recaptcha check
    if defined?(verify_recaptcha) && !verify_recaptcha
      flash[:error] = "Recaptcha did not match. Please try again."
      build_resource(user_params)
      render :new and return
    end

    Tenant.transaction do
      @tenant = Tenant.new(tenant_params)

      unless @tenant.save
        flash[:error] = @tenant.errors.full_messages.join(", ")
        build_resource(user_params)
        render :new and return
      end

      # Process premium payment if needed
      if @tenant.plan == "premium"
        @payment = Payment.new(
          email: user_params[:email],
          token: payment_params[:token],
          tenant: @tenant
        )

        unless @payment.valid?
          flash[:error] = "Please check payment errors"
          @tenant.destroy
          render :new and return
        end

        begin
          @payment.process_payment
          @payment.save
        rescue => e
          flash[:error] = e.message
          @tenant.destroy
          render :new and return
        end
      end

      # Create user under the tenant
      @user = User.new(user_params.merge(tenant_id: @tenant.id))

      unless @user.save
        flash[:error] = @user.errors.full_messages.join(", ")
        raise ActiveRecord::Rollback
      end

      # If confirmable is enabled, do not auto sign-in
      if @user.confirmed?
        sign_in(:user, @user)
        redirect_to root_path, notice: "Signup successful!"
      else
        # Sends confirmation email automatically
        flash[:notice] = "Please check your email to confirm your account."
        redirect_to root_path
      end
    end
  end

  protected

  def after_sign_up_path_for(resource)
    root_path
  end
end
