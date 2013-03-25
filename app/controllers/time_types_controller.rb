class TimeTypesController < ApplicationController

  load_and_authorize_resource

  def index
  end

  def new
  end

  def edit
  end

  def create
    if @time_type.save
      redirect_to time_types_path, :notice => 'Time Type was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    if @time_type.update_attributes(params[:time_type])
      redirect_to time_types_path, :notice => 'Time Type was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @time_type.destroy
      redirect_to time_types_path, :notice => 'Time Type was successfully deleted.'
    else
      render :action => 'edit'
    end
  end
end
