class AdjustmentsController < ApplicationController
  load_and_authorize_resource

  def index
    authorize! :manage, Adjustment
  end

  def new
  end

  def edit
  end

  def show
  end

  def create
    @adjustment = Adjustment.new(params[:adjustment])
    if @adjustment.save
      redirect_to adjustments_path, flash: {success: t('model_successfully_created', model: Adjustment.model_name.human)}
    else
      render :action => 'new'
    end
  end

  def update
    if @adjustment.update_attributes(params[:adjustment])
      redirect_to adjustments_path, flash: {success: t('model_successfully_updated', model: Adjustment.model_name.human)}
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @adjustment.destroy
      redirect_to adjustments_path, flash: {success: t('model_successfully_deleted', model: Adjustment.model_name.human)}
    else
      render :action => 'edit'
    end
  end

end
