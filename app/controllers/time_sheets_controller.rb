class TimeSheetsController < ApplicationController

  include DateHelper

  load_and_authorize_resource :time_sheet

  before_filter :load_day

  def show
    @week     = @day.at_beginning_of_week..@day.at_end_of_week
    @weekdays = @week.to_a
    @year     = @week.min.year
    @previous_week_day = (@week.min - 1).at_beginning_of_week
    @next_week_day = @week.max + 1

    @time_chunks = @time_sheet.find_chunks(@day, TimeType.work)
    # stuff for add form in modal
    @time_entry = TimeEntry.new
    if params[:date]
      @time_entry.start_date = params[:date]
    end
    @time_types = TimeType.work

    @timer = timer_on_day
    if @timer
      @timer_range = @timer.range.intersect(@day.to_range)
    end
    @timers_other_days = @time_sheet.time_entries.timers_not_in_range(@day.to_range)

    @public_holiday = PublicHoliday.on(@day).first

    @absences = {}
    @public_holidays = {}

    @weekdays.each do |weekday|
      absences =  @time_sheet.find_chunks(weekday, TimeType.absence)
      unless absences.empty?
        @absences[weekday] = absences.chunks
      end

      public_holiday = PublicHoliday.on(weekday).first
      if public_holiday
        @public_holidays[weekday] = public_holiday
      end
    end
  end

  def stop_timer
    timer_on_day.stop if timer_on_day
    render json: {}
  end

  def summary_for_date
    @total = @time_sheet.total(@day) + @time_sheet.duration_of_timers(@day)
    @bonus = @time_sheet.bonus(@day)

    @timer_duration_for_day = timer_on_day ? timer_on_day.duration(@day) : 0
    @timer_duration_since_start = timer_on_day ? timer_on_day.duration : 0

    week = @day.at_beginning_of_week..@day.at_end_of_week
    @week_total = @time_sheet.total(week) + @time_sheet.duration_of_timers(week)
  end

  private

  def timer_on_day
    @timer_on_day ||= @time_sheet.time_entries.timers_in_range(@day.to_range).first
  end

end
