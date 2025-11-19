class HomeController < ApplicationController
  # Uncomment if you want to require login
  # before_action :authenticate_user!, only: [:index]

  def index
    if session[:tenant_id]
      @tenant = Tenant.find_by(id: session[:tenant_id])
      Tenant.set_current_tenant(@tenant) if @tenant
    elsif current_user&.tenants&.any?
      @tenant = current_user.tenants.first
      Tenant.set_current_tenant(@tenant)
    else
      @tenant = nil
    end

    if @tenant
      @projects = Project.by_user_plan_and_tenant(@tenant.id, current_user)
      @project = Project.new  # ← Add this line
    else
      @projects = []
    end
  end
end