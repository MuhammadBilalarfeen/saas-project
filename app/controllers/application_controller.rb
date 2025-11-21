class ApplicationController < ActionController::Base
  helper_method :current_tenant

  # Ensure current_tenant is loaded for every request
  before_action :load_current_tenant

  private

  def current_tenant
    @current_tenant
  end

  def load_current_tenant
    if session[:tenant_id]
      @current_tenant ||= Tenant.find_by(id: session[:tenant_id])
    elsif current_user&.tenant
      @current_tenant ||= current_user.tenant
      session[:tenant_id] = @current_tenant.id
    end
  end
end