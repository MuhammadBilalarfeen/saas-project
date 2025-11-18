class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  before_action :set_tenant, only: %i[show edit update destroy new create]
  before_action :verify_tenant

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/1
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to root_url, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to root_url, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy!
    redirect_to root_url, notice: "Project was successfully destroyed."
  end


  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
  params.require(:project).permit(
    :title, :details, :expected_completion_date, :tenant_id, 
    :pdf_file, images: []
  )
end

  def set_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end

  def verify_tenant
  unless params[:tenant_id].to_i == Tenant.current_tenant&.id
    redirect_to root_url, flash: { error: 'You are not authorized to access any organization other than your own' }
  end
end
end