class UsersController < ApplicationController

  include UsersHelper

  load_and_authorize_resource
  before_filter :ensure_assigned_user_editable, only: [:edit, :update, :destroy]

  def index
    authorize! :manage, User
    @users = @users.sort_by { |u| u.active? ? 0 : 1 }
  end

  def new
  end

  def show
    redirect_to user_employments_path(@user), flash: flash
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_path, flash: {success: t('model_successfully_created', model: User.model_name.human)}
    else
      render :new
    end
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to users_path, flash: {success: t('model_successfully_updated', model: User.model_name.human)}
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, flash: {success: t('model_successfully_deleted', model: User.model_name.human)}
  end

  def activate
    authorize! :manage, User
    @user.update_attributes(active: params[:activate])
    redirect_to users_path, flash: {success: t(@user.active? ? 'users.activate.activating.success' : 'users.activate.deactivating.success', user: @user)}
  end
end
