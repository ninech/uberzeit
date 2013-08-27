class Summaries::Work::WorkController < ApplicationController

  before_filter :set_team
  before_filter :set_teams
  before_filter :set_year

  authorize_resource class: false

  def year
    @year = params[:year].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Work, users, UberZeit.year_as_range(@year))
  end

  def month
    @year = params[:year].to_i
    @month = params[:month].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Work, users, UberZeit.month_as_range(@year, @month))
  end

  private

  def set_team
    # this workaround where first thingy can be removed when this app runs on rails 4
    # accessible_by filters by id, a subsequent where(id: id) will replace the first one
    # (cf. rails activerecord/lib/active_record/relation/query_methods.rb, line 132)
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
