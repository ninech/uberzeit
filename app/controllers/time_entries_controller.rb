class TimeEntriesController < ApplicationController
  load_and_authorize_resource :time_sheet
  authorize_resource :time_entry, through: :time_sheet

  def new
  end

  def edit
    @entry = TimeEntry.find(params[:id])
    @time_types = TimeType.find_all_by_is_work(true)

    render 'edit', layout: false
  end

  def create
    @time_types = TimeType.find_all_by_is_work(true)

    @entry = @time_sheet.time_entries.new(params[:time_entry])
    @entry.save

    render json: @entry.errors
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
end
