class RolesController < ApplicationController
  load_and_authorize_resource :user

  def index
    @roles = @user.roles
  end

  def new
    @roles = Role::AVAILABLE_ROLES
    @teams = Team.all
    @user_role = UserRole.new
  end

  def create
  end
end

