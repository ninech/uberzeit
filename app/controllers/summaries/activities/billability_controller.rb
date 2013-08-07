class Summaries::Activities::BillabilityController < ApplicationController

  before_filter :check_access

  def index

  end

  private

  def check_access
    raise CanCan::AccessDenied unless current_user.admin? or current_user.team_leader?
  end

end
