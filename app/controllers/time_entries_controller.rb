class TimeEntriesController < ApplicationController
  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :time_entry, through: :time_sheet

  respond_to :html, :json, :js

  before_filter :load_time_types

  def new
  end

  def edit
  end

  def create
    @time_entry.save

    respond_with @time_entry, location: default_return_location
  end

  def update
    @time_entry.update_attributes(params[:time_entry])
    respond_with @time_entry, location: default_return_location
  end

  def destroy
    @time_entry.destroy
    respond_with(@time_entry, location: default_return_location) do |format|
      format.js { render nothing: true }
    end
  end

  private
  def default_return_location
    time_sheet_path(@time_sheet)
  end

  def load_time_types
    @time_types = TimeType.work
  end
end
