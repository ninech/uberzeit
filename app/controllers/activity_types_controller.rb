class ActivityTypesController < ApplicationController
  load_and_authorize_resource

  respond_to :html

  def index
    respond_with(@activity_types)
  end

  def new
  end

  def create
    @activity_type.save
    respond_with(@activity_type, location: activity_types_path)
  end

  def edit
  end

  def update
    @activity_type.update_attributes(params[:activity_type])
    respond_with(@activity_type, location: activity_types_path)
  end

  def destroy
    @activity_type.destroy
    respond_with(@activity_type, location: activity_types_path)
  end
end
