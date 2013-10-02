class Reports::Activities::FilterController < ApplicationController

  authorize_resource class: false

  before_filter :set_year, :set_month, :set_group_by

  def index
    @range = UberZeit.month_as_range(@year, @month)
    @allowed_group_by = %w{customer project activity_type}

    @sums = case @group_by
    when 'activity_type'
      Activity.sum_by_activity_type_and_year_and_month(@year, @month)
    when 'customer'
      Activity.sum_by_customer_and_year_and_month(@year, @month)
    when 'project'
      Activity.sum_by_project_and_year_and_month(@year, @month)
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
    @group_by = params[:group_by]
  end
end
