class Reports::Activities::DetailedController < ApplicationController
  authorize_resource class: false

  before_filter :set_year, :set_month, :set_customer

  def index
    @range = UberZeit.month_as_range(@year, @month)

    @activities = Activity.by_customer(@customer.id).with_date_in_year_and_month(@year, @month).where(reviewed: true)

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
  end

  private

  def set_year
    @year = params[:year].to_i
  end

  def set_month
    @month = params[:month].to_i
  end

  def set_customer
    customer_id = params[:customer_id]
    customer_id ||= Customer.first.id
    @customer = Customer.find(customer_id)
  end
end
