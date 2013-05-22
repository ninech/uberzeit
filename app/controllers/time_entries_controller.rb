class TimeEntriesController < ApplicationController
  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :time_entry, through: :time_sheet

  before_filter :load_time_types

  def new
  end

  def edit
    @time_entry = TimeEntry.find(params[:id])
  end

  def create

    if params[:time_entry][:to_time].blank?
      @time_entry = @time_sheet.timers.new(params[:time_entry].except(:to_time))
      @time_entry.save
    else
      @time_entry = @time_sheet.time_entries.new(params[:time_entry])
      @time_entry.save
    end

    render json: @time_entry.errors
  end

  def update
    @time_entry = TimeEntry.find(params[:id])

    if params[:time_entry][:to_time].blank?
      @timer = @time_sheet.timers.new(params[:time_entry].except(:to_time))
      @timer.save
      @time_entry.destroy

      render json: @timer.errors
    else
      @time_entry.update_attributes(params[:time_entry])
      render json: @time_entry.errors
    end
  end

  def destroy
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.destroy
    render json: {}
  end

  def exception_date
    rs = @time_entry.recurring_schedule
    rs.exception_dates.build(date: params[:date])
    rs.save!
    redirect_to @time_sheet, :notice => 'Exception date successfully added.'
  end

  private

  def load_time_types
    @time_types = TimeType.work
  end
end
