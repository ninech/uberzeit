class Reports::Vacation::VacationController < ApplicationController

  before_filter :set_team
  before_filter :set_teams
  before_filter :set_year

  authorize_resource class: false

  def year
    @table = Summarize::Table.new(Summarize::Summarizer::Vacation, users, UberZeit.year_as_range(@year))
  end

  def month
    @month = params[:month].to_i
    @month_as_date = Date.new(@year, @month)
    @table = Summarize::Table.new(Summarize::Summarizer::Vacation, users, UberZeit.month_as_range(@year, @month))
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
      User.joins(:teams).where(teams: {id: @teams.pluck(:id)})
    end
  end
end
