class EmploymentsController < ApplicationController

  load_and_authorize_resource :user
  load_and_authorize_resource :employment, through: :user

  def new
  end

  def edit
  end

  def index
  end

  def create
    @employment = Employment.new(params[:employment].merge(user: @user))
    if @employment.save and params[:open_ended].blank? || @employment.update_attribute(:end_date, nil)
      redirect_to user_path(@user), flash: {success: t('model_successfully_created', model: Employment.model_name.human)}
    else
      render :action => 'new'
    end
  end

  def update
    if @employment.update_attributes(params[:employment]) and params[:open_ended].blank? || @employment.update_attribute(:end_date, nil)
      redirect_to user_path(@user), flash: {success: t('model_successfully_updated', model: Employment.model_name.human)}
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @employment.destroy
      redirect_to user_path(@user), flash: {success: t('model_successfully_deleted', model: Employment.model_name.human)}
    else
      render :action => 'edit'
    end
  end

  private

end
