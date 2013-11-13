class TeamsController < ApplicationController

  load_and_authorize_resource

  def index
    authorize! :manage, Team
  end

  def new
  end

  def edit
  end

  def create
    @team = Team.new(params[:team])
    if @team.save
      redirect_to teams_path, flash: {success: t('model_successfully_created', model: Team.model_name.human)}
    else
      render :new
    end
  end

  def update
    if @team.update_attributes(params[:team])
      redirect_to teams_path, flash: {success: t('model_successfully_updated', model: Team.model_name.human)}
    else
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_path, flash: {success: t('model_successfully_deleted', model: Team.model_name.human)}
  end
end
