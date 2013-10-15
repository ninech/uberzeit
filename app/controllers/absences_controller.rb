class AbsencesController < ApplicationController
  load_and_authorize_resource :user
  load_and_authorize_resource :absence, through: :user

  respond_to :html, :json, :js

  before_filter :load_time_types

  def index
    year = params[:year] || Time.current.year
    @year = year.to_i

    @absences = {}

    time_spans = @user.time_spans.absences.with_date_in_year(@year)
    time_spans.each do |time_span|
      date = time_span.date
      @absences[date] ||= []
      @absences[date] << time_span.time_spanable
    end

    @public_holidays = {}
    PublicHoliday.with_date_in_year(@year).each do |public_holiday|
      @public_holidays[public_holiday.date] = public_holiday
    end

    respond_with(@absences)
  end

  def new
    @absence.build_schedule
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
    @absence.build_schedule unless @absence.schedule
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
    year_user_absences_path(@user, @absence.start_date.year) if @absence.start_date
  end

  def load_time_types
    @time_types = TimeType.absence
  end
end
