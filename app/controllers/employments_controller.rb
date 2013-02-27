class EmploymentsController < ApplicationController
  before_filter :load_user

  def index
    @employments = @user.employments
  end

  def new
    @employment = Employment.new
  end

  def edit
    @employment = Employment.find(params[:id])
  end

  def create
    @employment = Employment.new(params[:employment])
    @user.employments << @employment
    if @employment.save and params[:open_ended].blank? || @employment.update_attribute(:end_date, nil)
      redirect_to [@employment.user, @employment], :notice => 'Employment was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    @employment = Employment.find(params[:id])
    if @employment.update_attributes(params[:employment]) and params[:open_ended].blank? || @employment.update_attribute(:end_date, nil)
      redirect_to [@employment.user, @employment], :notice => 'Employment was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @employment = Employment.find(params[:id])
    if @employment.destroy
      redirect_to user_employments_path(@user), :notice => 'Employment was successfully deleted.'
    else
      render :action => 'edit'
    end
  end

  private

  def load_user
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
  end
end
