class TimeTypesController < ApplicationController
  def index
    @time_types = TimeType.all
  end

  def new
    @time_type = TimeType.new
  end

  def edit
    @time_type = TimeType.find(params[:id])
  end

  def create
    @time_type = TimeType.new(params[:time_type])
    if @time_type.save
      redirect_to time_types_path, :notice => 'Time Type was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    @time_type = TimeType.find(params[:id])
    if @time_type.update_attributes(params[:time_type])
      redirect_to time_types_path, :notice => 'Time Type was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @time_type = TimeType.find(params[:id])
    if @time_type.destroy
      redirect_to time_types_path, :notice => 'Time Type was successfully deleted.'
    else
      render :action => 'edit'
    end
  end 
end
