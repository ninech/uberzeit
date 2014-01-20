class Reports::Activities::FilterController < ApplicationController

  authorize_resource class: Activity

  before_filter :set_year, :set_month, :set_group_by

  def index
    @start_date = Date.parse(params[:start_date] || Date.today.beginning_of_month.to_s)
    @end_date = Date.parse(params[:end_date] || Date.today.end_of_month.to_s)

    @activities = Activity.with_date(@start_date..@end_date)

    @allowed_group_by = %w{customer project activity_type}

    @sums = case @group_by
            when 'activity_type'
              @activities.sum_by_activity_type
            when 'customer'
              @activities.sum_by_customer
            when 'project'
              @activities.sum_by_project
            end

    @totals = {}
    @sums.each do |group, sum|
      [:duration, :billable, :not_billable].each do |type|
        @totals[type] ||= 0
        @totals[type] += sum[type] if sum[type]
      end
    end
  end

  private

  def set_year
    @year = params[:year].to_i
  end

  def set_month
    @month = params[:month].to_i
  end

  def set_group_by
    @group_by = params[:group_by] || 'activity_type'
  end
end
