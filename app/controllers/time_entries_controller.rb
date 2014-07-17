class TimeEntriesController < ApplicationController

  include Concerns::WeekView

  load_and_authorize_resource :user
  load_and_authorize_resource :time_entry, through: :user

  respond_to :html, :json, :js

  before_filter :load_day
  before_filter :load_week_total
  before_filter :load_time_types
  before_filter :prepare_week_view, :prepare_weekday_sums, only: :index
  before_filter :set_end_date, only: [:create, :update]

  def index
    prepare_week_view
    @time_spans_of_time_entries = @user.time_spans
                                       .effective_working_time
                                       .with_date(@day)
                                       .sort_by { |time_span| time_span.time_spanable.starts }

    @time_spans_of_absences = @user.time_spans.absences.with_date(@day)
    @current_public_holiday = @public_holidays[@day]

    @timer = timer_on_day
    if @timer
      @timer_range = @timer.range.intersect(@day.to_range)
    end
    @timers_other_days = @user.time_entries.timers_not_in_range(@day.to_range)
  end

  def new
    if params[:date]
      @time_entry.start_date = params[:date]
    end
  end

  def edit
  end

  def create
    adjust_timer_day_boundary
    @time_entry.user_id = params[:user_id] if params[:user_id]
    @time_entry.save
    respond_with @time_entry, location: default_return_location
  end

  def update
    @time_entry.update_attributes(params[:time_entry])
    adjust_timer_day_boundary
    @time_entry.save
    respond_with @time_entry, location: default_return_location
  end

  def destroy
    @time_entry.destroy
    respond_with @time_entry, location: default_return_location
  end

  def summary_for_date
    @total = @user.time_sheet.working_time_without_adjustments_total(@day) + @user.time_sheet.duration_of_timers(@day)
    @bonus = @user.time_sheet.bonus(@day)

    @timer_duration_for_day = timer_on_day ? timer_on_day.duration(@day) : 0
    @timer_duration_since_start = timer_on_day ? timer_on_day.duration : 0
  end

  def stop_timer
    timer_on_day.stop if timer_on_day
    render json: {}
  end

  private
  def adjust_timer_day_boundary
    if !@time_entry.timer? && @time_entry.starts && @time_entry.ends < @time_entry.starts
      @time_entry.end_date = @time_entry.start_date + 1
    end
  end

  def set_end_date
    if params[:time_entry][:end_date].blank? && params[:time_entry][:end_time].present?
      params[:time_entry][:end_date] ||= params[:time_entry][:start_date]
    end
  end

  def default_return_location
    user_time_entries_path(@user)
  end

  def load_time_types
    @time_types = TimeType.work
  end

  def timer_on_day
    @timer_on_day ||= @user.time_entries.timers_in_range(@day.to_range).first
  end

  def load_week_total
    week = @day.at_beginning_of_week..@day.at_end_of_week
    @week_total = @user.time_sheet.working_time_without_adjustments_total(week) + @user.time_sheet.duration_of_timers(week)
  end

  def prepare_weekday_sums
    @weekday_sums = {}
    @weekdays.each do |weekday|
      @weekday_sums[weekday] = worktime_for_range(weekday)
    end
  end

end
