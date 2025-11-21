class ConfirmationsController < ApplicationController
  before_action :set_confirmable, only: [:show]

  # --- SHOW METHOD (updated from Milia docs) ---
  def show
    if @confirmable.new_record? ||
       !defined?(Milia) ||                             # since you said Milia isn't loading
       @confirmable.respond_to?(:skip_confirm_change_password) &&
       @confirmable.skip_confirm_change_password

      # Pass-through confirmation
      Rails.logger.info("===== devise pass-thru =====")

      self.resource = User.confirm_by_token(params[:confirmation_token])

      yield resource if block_given?

      if resource.errors.empty?
        flash[:notice] = "Your account has been confirmed successfully."
      end

      # If Milia password skipping is enabled
      if @confirmable.respond_to?(:skip_confirm_change_password) &&
         @confirmable.skip_confirm_change_password
        sign_in(resource)
        redirect_to root_path and return
      end

    else
      # Password setting form
      Rails.logger.info("===== password set form =====")

      flash[:notice] = "Please choose a password and confirm it"
      prep_do_show
    end
  end


  # --- AFTER CONFIRMATION ---
  def after_confirmation_path_for(resource_name, resource)
    if user_signed_in?
      root_path
    else
      new_user_session_path
    end
  end


  private

  # --- SET CONFIRMABLE ---
  def set_confirmable
    @confirmable = User.find_or_initialize_with_error_by(
      :confirmation_token,
      params[:confirmation_token]
    )
  end


  # --- NEEDED FOR PASSWORD FORM (Milia method) ---
  def prep_do_show
    # create the minimum instance variables needed by the password-confirmation form
    @resource = @confirmable
    @confirmation_token = params[:confirmation_token]
    render :show
  end
end