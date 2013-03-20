class AbsencesController < ApplicationController

  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :absence, through: :time_sheet

  respond_to :html, :json

  def index
    year = params[:year] || Time.current.year
    @year = year.to_i

    @time_types = TimeType.absences
    @absences = {}
    time_chunks_finder = FindTimeChunks.new(@time_sheet.absences)
    time_chunks_finder.in_year(@year).each do |chunk|
      chunk.range.to_date_range.each do |day|
        @absences[day.to_s] ||= []
        @absences[day.to_s] << chunk
      end
    end
  end

  def new
    @time_types = TimeType.absences
    @absence.build_recurring_schedule

    respond_with(@absence, :layout => !request.xhr?)
  end

  def create
    @absence.save
    respond_with(@absence, location: default_return_location)
  end

  def edit
    @time_types = TimeType.absences
    @absence.build_recurring_schedule unless @absence.recurring_schedule
    respond_with(@absence, :layout => !request.xhr?)
  end

  def update
    @absence.update_attributes(params[:absence])
    respond_with(@absence, location: default_return_location)
  end

  def destroy
    @absence.destroy
    respond_with(@absence, location: default_return_location)
  end

  private
  def default_return_location
    year_time_sheet_absences_path(@time_sheet, @absence.start_date.year)
  end

end
