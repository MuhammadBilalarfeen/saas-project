class HomeController < ApplicationController
  def index
    if session[:tenant_id]
      @tenant = Tenant.find_by(id: session[:tenant_id])
    elsif current_user&.tenant&.any?
      @tenant = current_user.tenant.first
      session[:tenant_id] = @tenant.id
    end

    Tenant.set_current_tenant(@tenant) if @tenant

    # Ensure @project exists for form in home page
    @project = Project.new if @tenant
    @projects = @tenant ? Project.by_user_plan_and_tenant(@tenant.id, current_user) : []
  end
end