class AbsencesController < ApplicationController

  load_and_authorize_resource :time_sheet

  def index
    first_day_of_year = Time.zone.local(params[:year] || Time.now.year)
    year_range = first_day_of_year...(first_day_of_year + 1.year)
    #@absences = @time_sheet.find_chunks(year_range)
  end
end
