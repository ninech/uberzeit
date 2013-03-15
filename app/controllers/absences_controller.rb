class AbsencesController < ApplicationController

  load_and_authorize_resource :time_sheet

  def index
    year = params[:year] || Time.current.year
    @year = year.to_i
    first_day_of_year = Time.zone.local(@year)
    year_range = first_day_of_year.to_date...(first_day_of_year + 1.year).to_date

    @time_types = TimeType.absences
    @absences = {}
    time_chunks_finder = FindTimeChunks.new([@time_sheet.date_entries.absence, @time_sheet.time_entries.absence])
    time_chunks_finder.in_year(@year).each do |chunk|
      chunk.range.to_date_range.each do |day|
        @absences[day.to_s] = chunk.time_type
      end
    end

    @time_entry = @time_sheet.time_entries.new
    @date_entry = @time_sheet.date_entries.new
  end
end
