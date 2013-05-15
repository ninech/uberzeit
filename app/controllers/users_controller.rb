class UsersController < ApplicationController

  load_and_authorize_resource

  def index
    authorize! :manage, User
  end

  def show
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to edit_user_path(@user), :notice => 'Settings were successfully updated.'
    else
      render :edit
    end
  end
end
