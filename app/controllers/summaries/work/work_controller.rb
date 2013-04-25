class Summaries::Work::WorkController < ApplicationController

  before_filter :set_team
  before_filter :set_teams
  before_filter :set_year

  def year
    @year = params[:year].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Work, @team || User.all, UberZeit.year_as_range(@year))
  end

  def month
    @year = params[:year].to_i
    @month = params[:month].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Work, @team || User.all, UberZeit.month_as_range(@year, @month))
  end

  private

  def set_team
    @team = Team.find(params[:team_id]) unless params[:team_id].blank?
  end

  def set_teams
    @teams = Team.all
  end

  def set_year
    @year = params[:year].to_i
  end
end
