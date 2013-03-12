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

    @time_entries = @time_sheet.find_chunks(@day)
    @time_entry = TimeEntry.new
  end

end
