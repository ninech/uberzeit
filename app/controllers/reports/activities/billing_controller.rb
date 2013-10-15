class Reports::Activities::BillingController < ApplicationController

  authorize_resource class: false

  def index
    @activities = ::Activity.accessible_by(current_ability)
                            .where(billable: true, reviewed: true, billed: false)

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
