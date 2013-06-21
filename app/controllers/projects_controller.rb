class ProjectsController < ApplicationController
  load_and_authorize_resource

  respond_to :html

  def index
    @projects = @projects.includes(:customer).all.group_by { |project| project.customer }
    respond_with(@projects)
  end

  def new
  end

  def create
    @project.save
    respond_with(@project, location: projects_path)
  end

  def edit
  end

  def update
    @project.update_attributes(params[:project])
    respond_with(@project, location: projects_path)
  end

  def destroy
    @project.destroy
    respond_with(@project, location: projects_path)
  end
end
