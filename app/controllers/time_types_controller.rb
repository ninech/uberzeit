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
      redirect_to time_types_path, :notice => t('model_successfully_created', model: TimeType.model_name.human)
    else
      render :action => 'new'
    end
  end

  def update
    if @time_type.update_attributes(params[:time_type])
      redirect_to time_types_path, :notice => t('model_successfully_updated', model: TimeType.model_name.human)
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @time_type.destroy
      redirect_to time_types_path, :notice => t('model_successfully_deleted', model: TimeType.model_name.human)
    else
      render :action => 'edit'
    end
  end
end
