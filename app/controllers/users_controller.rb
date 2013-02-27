class UsersController < ApplicationController

  def index
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
