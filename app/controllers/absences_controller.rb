class AbsencesController < ApplicationController

  load_and_authorize_resource :time_sheet

  def index
    @year = params[:year] || Time.current.year
    first_day_of_year = Time.zone.local(@year)
    year_range = first_day_of_year.to_date...(first_day_of_year + 1.year).to_date

    @time_types = TimeType.absences
    @absences = {}
    TimeChunkCollection.new(year_range, [@time_sheet.date_entries, @time_sheet.time_entries], :absence).each do |chunk|
      chunk.range.to_date_range.each do |day|
        @absences[day.to_s] = chunk.time_type
      end
    end
  end
end
