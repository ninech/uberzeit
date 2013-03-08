class TimeSheetsController < ApplicationController
  load_and_authorize_resource :time_sheet

  def index

  end

  def show
    @day      = Time.zone.today
    @week     = @day.at_beginning_of_week..@day.at_end_of_week
    @weekdays = @week.to_a
    @year     = @week.min.year

    @time_entries = @time_sheet.find_chunks(@day)
  end

end
