class Reports::BaseController < ApplicationController
  before_filter :set_info

  private

  def set_info
    @month = requested_month
    @year = requested_year
    if requested_year && requested_month
      @month_as_date = Date.new(requested_year, requested_month)
    end
    @requested_teams = requested_teams
    @users = requested_users
    @teams = accessible_teams
  end

  def accessible_teams
    Team.accessible_by(current_ability)
  end

  def accessible_users
    User.only_active.accessible_by(current_ability)
  end

  def requested_teams
    # accessible_by filters by id, a subsequent where(id: id) will replace the first one
    # (cf. rails activerecord/lib/active_record/relation/query_methods.rb, line 132)
    return accessible_teams unless params[:team_ids].present?
    accessible_teams.where('id IN (?)', params[:team_ids].map(&:to_i))
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
    when requested_teams
      accessible_users.in_teams(requested_teams)
    else
      accessible_users
    end
  end
end
