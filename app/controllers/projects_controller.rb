class ProjectsController < ApplicationController
  load_and_authorize_resource
  before_filter :extract_customer_id, only: [:update, :create]

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

  private
  def extract_customer_id
    unless params[:project][:customer_id].blank?
      match = params[:project][:customer_id].match(/\d+/)
      match[0] if match
    end
  end
end
