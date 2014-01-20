class Reports::Activities::BillabilityController < ApplicationController

  authorize_resource class: false

  def index
    @date = params[:date].present? ? params[:date].to_date : Date.today.beginning_of_week(:sunday)
    @activities = ::Activity.accessible_by(current_ability, :update)
                            .where(reviewed: false)
                            .where('date <= ?', @date)

    # group activities so the result looks like this:
    #  yolo_inc => { support => [a1, a2], maintenance => [a3] },
    #  swag_ag => { support => [a4] }
    @grouped_activities = {}
    @activities.each do |a|
      next if a.customer.nil?
      @grouped_activities[a.customer] ||= {}
      @grouped_activities[a.customer][a.activity_type] ||= []
      @grouped_activities[a.customer][a.activity_type] << a
    end
  end

end
