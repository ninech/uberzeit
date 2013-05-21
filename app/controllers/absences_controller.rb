class AbsencesController < ApplicationController
  before_filter :load_time_types

  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :absence, through: :time_sheet

  respond_to :html, :json

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
    if @absence.save
      respond_with(@absence) do |format|
        format.js { render js: "window.location = #{default_return_location.to_json}" }
      end
    else
      respond_with(@absence, status: 400)
    end
  end

  def edit
    @absence.build_recurring_schedule unless @absence.recurring_schedule
    respond_with(@absence)
  end

  def update
    if @absence.update_attributes(params[:absence])
      respond_with(@absence) do |format|
        format.js { render js: "window.location = #{default_return_location.to_json}" }
      end
    else
      respond_with(@absence, status: 400)
    end
  end

  def destroy
    @absence.destroy
    respond_with(@absence, location: default_return_location)
  end

  private
  def default_return_location
    year_time_sheet_absences_path(@time_sheet, @absence.start_date.year)
  end

  def load_time_types
    @time_types = TimeType.absence
  end
end
