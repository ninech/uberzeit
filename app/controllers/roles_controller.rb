class RolesController < ApplicationController
  load_and_authorize_resource :user

  def index
    @roles = @user.roles
  end

  def new
    @user_role = UserRole.new
  end

  def create
    @user_role = UserRole.new
    @user_role.user = @user
    @user_role.role = params[:user_role][:role]
    @user_role.resource = Team.find(params[:user_role][:resource]) unless params[:user_role][:resource].blank?
    if @user_role.create
      redirect_to user_roles_path(@user), flash: {success: t('model_successfully_created', model: UserRole.model_name.human)}
    else
      render :new
    end
  end
end

