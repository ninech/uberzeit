class Summaries::Work::WorkController < ApplicationController

  before_filter :load_team
  before_filter :load_teams

  def year
    @teams = Team.all
    @year = params[:year].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Work, @team || User.all, UberZeit.year_as_range(@year))
    @entries = @table.entries
  end

  def month
    @year = params[:year].to_i
    @month = params[:month].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Work, @team || User.all, UberZeit.month_as_range(@year, @month))
    @entries = @table.entries
  end

  private

  def load_team
    @team = Team.find(params[:team_id]) unless params[:team_id].blank?
  end

  def load_teams
    @teams = Team.all
  end
end
