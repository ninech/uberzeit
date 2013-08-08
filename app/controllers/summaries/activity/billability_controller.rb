class Summaries::Activity::BillabilityController < ApplicationController

  before_filter :check_access

  def index
    @activities = ::Activity.joins(:user)
                            .joins(:user => :teams)
                            .where(:teams => {id: Team.accessible_by(current_ability)})
                            .uniq

    # group activities so the result looks like this:
    #  yolo_inc => { support => [a1, a2], maintenance => [a3] },
    #  swag_ag => { support => [a4] }
    @grouped_activities = {}
    @activities.each do |a|
      @grouped_activities[a.customer] ||= {}
      @grouped_activities[a.customer][a.activity_type] ||= []
      @grouped_activities[a.customer][a.activity_type] << a
    end
  end

  private

  def check_access
    raise CanCan::AccessDenied unless current_user.admin? or current_user.team_leader?
  end

end
