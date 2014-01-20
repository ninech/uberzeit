class Reports::Activities::DetailedController < ApplicationController
  authorize_resource class: Activity

  before_filter :set_year, :set_month, :set_customer

  def index
    @start_date = Date.parse(params[:start_date] || Date.today.beginning_of_month.to_s)
    @end_date = Date.parse(params[:end_date] || Date.today.end_of_month.to_s)

    @activities = Activity.by_customer(@customer.id).with_date(@start_date..@end_date).where(reviewed: true)

    @grouped_activities = {}
    @subtotals = {}
    @totals = {}
    @activities.each do |a|
      @grouped_activities[a.activity_type] ||= []
      @grouped_activities[a.activity_type] << a

      @subtotals[a.activity_type] ||= {}
      @subtotals[a.activity_type][:billable]     ||= 0
      @subtotals[a.activity_type][:not_billable] ||= 0
      @subtotals[a.activity_type][:billed]       ||= 0
      @subtotals[a.activity_type][:billable]     += a.duration if a.billable?
      @subtotals[a.activity_type][:not_billable] += a.duration unless a.billable?
      @subtotals[a.activity_type][:billed]       += a.duration if a.billed

      @totals[:billable]     ||= 0
      @totals[:not_billable] ||= 0
      @totals[:billed]       ||= 0
      @totals[:billable]     += a.duration if a.billable?
      @totals[:not_billable] += a.duration unless a.billable?
      @totals[:billed]       += a.duration if a.billed
    end

    @billed_vs_billable_percentage = @totals[:billed].to_f / @totals[:billable].to_f * 100
  end

  private

  def set_year
    @year = params[:year].to_i
  end

  def set_month
    @month = params[:month].to_i
  end

  def set_customer
    if params[:customer].present?
      match = params[:customer].match(/\A(\d+)/)
      customer_number = match.captures.first
    end
    customer_number ||= Customer.first.number
    @customer = Customer.find_by_number(customer_number)
  end
end
