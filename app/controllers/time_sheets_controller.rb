class TimeSheetsController < ApplicationController
  load_and_authorize_resource :time_sheet

  def show
    unless params[:date].nil?
      @day = Time.zone.parse(params[:date]).to_date
    end

    @day ||= Time.zone.today

    @week     = @day.at_beginning_of_week..@day.at_end_of_week
    @weekdays = @week.to_a
    @year     = @week.min.year
    @previous_week_day = (@week.min - 1).at_beginning_of_week
    @next_week_day = @week.max + 1

    @time_chunks = {}
    @time_chunks[:work] = @time_sheet.find_chunks(@day, TimeType.work)
    @time_chunks[:absence] = @time_sheet.find_chunks(@day, TimeType.absence)
    # stuff for add form in modal
    @time_entry = TimeEntry.new
    if params[:date]
      @time_entry.start_date = params[:date]
    end
    @time_types = TimeType.work

    @timer = @time_sheet.timer
    unless @timer.nil?
      @timer_active = @timer.start_date == (params[:date] || Time.current.to_date.to_s(:db))
    end

    @public_holiday = PublicHoliday.on(@day).first

    @absences = {}
    @public_holidays = {}

    @weekdays.each do |weekday|
      absences =  @time_sheet.find_chunks(weekday, TimeType.absence)
      unless absences.chunks.empty?
        @absences[weekday] = absences.chunks[0]
      end

      public_holiday = PublicHoliday.on(weekday).first
      if public_holiday
        @public_holidays[weekday] = public_holiday
      end
    end

    @legend_show_public_holiday = @public_holidays.any?
    @legend_time_types = TimeType.absence.select do |time_type|
      @absences.any?{ |date, absence| absence.time_type == time_type }
    end
  end

  def stop_timer
    @time_sheet.timer.stop

    render json: {}
  end

end
