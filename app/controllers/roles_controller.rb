class RolesController < ApplicationController
  load_and_authorize_resource :user

  before_filter :ensure_authorized_for_role_management

  def index
    @roles = @user.roles.order(:name)
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

  def destroy
    role = Role.find(params[:id])
    @user.remove_role(role.name, role.resource)
    redirect_to user_roles_path(@user)
  end

  private
  def ensure_authorized_for_role_management
    authorize! :manage, Role
  end
end

