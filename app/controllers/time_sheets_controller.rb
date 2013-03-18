class TimeSheetsController < ApplicationController
  load_and_authorize_resource :time_sheet

  def index

  end

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

    @time_chunks = @time_sheet.find_chunks(@day)

    # stuff for add form in modal
    @time_entry = TimeEntry.new
    if params[:date]
      @time_entry.start_date = params[:date]
    end
    @time_types = TimeType.find_all_by_is_work(true)

    @timer = @time_sheet.timer
    unless @timer.nil?
      @timer_active = @timer.start_date == (params[:date] || Time.current.to_date.to_s(:db))
    end
  end

  def stop_timer
    @time_sheet.timer.stop

    render json: {}
  end

end
