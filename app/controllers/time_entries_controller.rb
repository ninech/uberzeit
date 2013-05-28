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
    @entry = @time_sheet.time_entries.new(params[:time_entry])
    @entry.save

    render json: @time_entry.errors
  end

  def update
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.update_attributes(params[:time_entry])
    render json: @time_entry.errors
  end

  def destroy
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.destroy
    render json: {}
  end

  private
  def load_time_types
    @time_types = TimeType.work
  end
end
