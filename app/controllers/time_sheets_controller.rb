class TimeSheetsController < ApplicationController

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

    @timer = @time_sheet.timers.on(@day).first
    unless @timer.nil?
      @timer_active = (@timer.start_date.to_date == @day.to_date) # (params[:date] || Time.current.to_date.to_s(:db))
    end
    @timers_other_days = @time_sheet.timers.others(@day).order('start_time')

    @public_holiday = PublicHoliday.on(@day).first

    @absences = {}
    @public_holidays = {}

    @weekdays.each do |weekday|
      absences =  @time_sheet.find_chunks(weekday, TimeType.absence)
      unless absences.empty?
        @absences[weekday] = absences
      end

      public_holiday = PublicHoliday.on(weekday).first
      if public_holiday
        @public_holidays[weekday] = public_holiday
      end
    end

    @legend_show_public_holiday = @public_holidays.any?
    @legend_time_types = TimeType.absence.select do |time_type|
      @absences.any? do |date, absences|
        absences.chunks.any? { |absence| absence.time_type == time_type }
      end
    end
  end

  def stop_timer
    timer = @time_sheet.timers.on(@day).first
    timer.stop

    render json: {}
  end

  def summary_for_date
    @total = @time_sheet.total(@day) + @time_sheet.duration_of_timers(@day)
    @bonus = @time_sheet.bonus(@day)

    active_timer = @time_sheet.timers.on(@day).first
    @timer =  if active_timer.nil?
                0
              else
                active_timer.duration(@day)
              end
  end

  private

  def load_day
    unless params[:date].nil?
      @day = Time.zone.parse(params[:date]).to_date
    end
    @day ||= Time.zone.today
  end

end
