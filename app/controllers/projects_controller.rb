class ProjectsController < ApplicationController
  load_and_authorize_resource

  def index
    @projects = @projects.includes(:customer).all.group_by { |project| project.customer }
  end

  def create
  end

  def update
  end

  def destroy
  end
end
