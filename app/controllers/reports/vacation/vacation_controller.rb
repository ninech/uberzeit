class Reports::Vacation::VacationController < ApplicationController

  before_filter :set_team
  before_filter :set_teams
  before_filter :set_year

  authorize_resource class: false

  def year
    @users = users
  end

  def month
    @month = params[:month].to_i
    @month_as_date = Date.new(@year, @month)
    @users = users
  end

  private

  def set_team
    @team = Team.accessible_by(current_ability).where('id = ?', params[:team_id]).first unless params[:team_id].blank?
  end

  def set_teams
    @teams = Team.accessible_by(current_ability)
  end

  def set_year
    @year = params[:year].to_i
  end

  def users
    if @team
      @team.members
    else
      User.in_teams(@teams)
    end
  end
end
