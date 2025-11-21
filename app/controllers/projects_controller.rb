class ProjectsController < ApplicationController
  before_action :set_tenant
  before_action :set_project, only: %i[show edit update destroy users add_user remove_user]
  before_action :verify_tenant

  # GET /tenants/:tenant_id/projects
  def index
    @projects = Project.by_user_plan_and_tenant(@tenant.id, current_user)
    @project = Project.new
  end

  # GET /tenants/:tenant_id/projects/new
  def new
    @project = Project.new
  end

  # POST /tenants/:tenant_id/projects
  def create
    @project = @tenant.projects.new(project_params)

    if @project.save
      # Add the current user after the project is saved
      @project.users << current_user unless @project.users.include?(current_user)
      redirect_to tenant_projects_path(@tenant), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tenants/:tenant_id/projects/:id/edit
  def edit; end

  # PATCH/PUT /tenants/:tenant_id/projects/:id
  def update
    if @project.update(project_params)
      redirect_to tenant_projects_path(@tenant), notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tenants/:tenant_id/projects/:id
  def destroy
    @project.destroy!
    redirect_to tenant_projects_path(@tenant), notice: "Project was successfully destroyed."
  end

  # GET /tenants/:tenant_id/projects/:id/users
  def users
    # Users already on the project (exclude current_user)
    @project_users = @project.users.where.not(id: current_user.id)

    # Users in this tenant, excluding current_user and already on project
    @other_users = User.where(tenant_id: @tenant.id)
                       .where.not(id: @project.users.pluck(:id) + [current_user.id])
  end

  # POST /tenants/:tenant_id/projects/:id/add_user
  def add_user
  user = User.find(params[:user_id])
  unless @project.users.include?(user)
    @project.users << user
    user.update(tenant_id: @project.tenant_id) # Assign tenant dynamically
  end
  redirect_to users_tenant_project_path(@project, tenant_id: @project.tenant_id)
end

  # DELETE /tenants/:tenant_id/projects/:id/remove_user
  def remove_user
    user = User.find(params[:user_id])
    @project.users.destroy(user) if @project.users.include?(user)

    redirect_to users_tenant_project_path(@tenant, @project), notice: "#{user.email} removed from project."
  end

  private

  def set_tenant
    @tenant = Tenant.find_by(id: params[:tenant_id]) || Tenant.current_tenant
  end

  def set_project
    @project = Project.find(params[:id]) if params[:id]
  end

  def verify_tenant
    unless @tenant && @tenant.id == Tenant.current_tenant&.id
      redirect_to root_url, flash: { error: 'You are not authorized to access this organization' }
    end
  end

  def project_params
    params.require(:project).permit(:title, :details, :expected_completion_date, :pdf_file, images: [])
  end
end