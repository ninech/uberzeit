class AbsencesController < ApplicationController
  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :absence, through: :time_sheet

  respond_to :html, :json, :js

  before_filter :load_time_types

  def index
    year = params[:year] || Time.current.year
    @year = year.to_i

    @absences = {}
    time_chunks_finder = FindTimeChunks.new(@time_sheet.absences)
    time_chunks_finder.in_year(@year).each do |chunk|
      chunk.range.to_date_range.each do |day|
        @absences[day.to_s] ||= []
        @absences[day.to_s] << chunk
      end
    end

    @public_holidays = {}
    PublicHoliday.in_year(@year).each do |public_holiday|
      @public_holidays[public_holiday.start_date.to_s] = public_holiday
    end
  end

  def new
    @absence.build_recurring_schedule
    if params[:date]
      @absence.start_date = params[:date].to_date
      @absence.end_date = @absence.start_date
    end
    respond_with(@absence)
  end

  def create
    @absence.save
    respond_with @absence, location: default_return_location
  end

  def edit
    @absence.build_recurring_schedule unless @absence.recurring_schedule
    respond_with(@absence)
  end

  def update
    @absence.update_attributes(params[:absence])
    respond_with @absence, location: default_return_location
  end

  def destroy
    @absence.destroy
    respond_with(@absence, location: default_return_location) do |format|
      format.js { render nothing: true }
    end
  end

  private
  def default_return_location
    year_time_sheet_absences_path(@time_sheet, @absence.start_date.year) if @absence.start_date
  end

  def load_time_types
    @time_types = TimeType.absence
  end
end
