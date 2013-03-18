class AbsenceTimeEntriesController < ApplicationController

  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :time_entry, through: :time_sheet, class: 'TimeEntry', parent: false

  respond_to :html, :json

  def create
    @time_entry.save

    respond_with(@time_entry, location: year_time_sheet_absences_path(@time_sheet, @time_entry.starts.year))
  end

end
