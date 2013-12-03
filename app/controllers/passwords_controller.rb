class PasswordsController < ApplicationController
  include UsersHelper

  load_and_authorize_resource :user
  before_filter :ensure_assigned_user_editable, only: [:edit, :update]

  def edit
  end

  def update
    if @user.update_attributes(password_params)
      redirect_to edit_user_password_path(@user), flash: {success: t('model_successfully_updated', model: User.model_name.human)}
    else
      render :edit
    end
  end

  private
  def password_params
    params[:password].slice(:password, :password_confirmation)
  end
end
