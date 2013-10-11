class Reports::BaseController < ApplicationController
  before_filter :set_info

  private

  def set_info
    @month = requested_month
    @year = requested_year
    @users = requested_users || accessible_users
    @teams = accessible_teams
    @team = requested_team
    @month_as_date = Date.new(requested_year, requested_month) if requested_year and requested_month
  end

  def accessible_teams
    Team.accessible_by(current_ability)
  end

  def accessible_users
    User.accessible_by(current_ability)
  end

  def requested_team
    # this workaround where first thingy can be removed when this app runs on rails 4
    # accessible_by filters by id, a subsequent where(id: id) will replace the first one
    # (cf. rails activerecord/lib/active_record/relation/query_methods.rb, line 132)
    accessible_teams.where('id = ?', params[:team_id]).first unless params[:team_id].blank?
  end

  def requested_user
    accessible_users.where('id = ?', params[:user_id]).first unless params[:user_id].blank?
  end

  def requested_month
    params[:month].present? ? params[:month].to_i : nil
  end

  def requested_year
    params[:year].present? ? params[:year].to_i : nil
  end

  def requested_users
    case
    when requested_user
      [requested_user]
    when requested_team
      requested_team.members
    end
  end
end
