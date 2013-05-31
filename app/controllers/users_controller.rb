class UsersController < ApplicationController

  load_and_authorize_resource

  def index
    authorize! :manage, User
  end

  def show
    redirect_to user_employments_path(@user), flash: flash
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to edit_user_path(@user), :notice => 'Settings were successfully updated.'
    else
      render :edit
    end
  end
end
