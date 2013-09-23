class TimeEntriesController < ApplicationController
  load_and_authorize_resource :user
  load_and_authorize_resource :time_entry, through: :user

  respond_to :html, :json, :js

  before_filter :load_time_types
  before_filter :set_end_date, only: [:create, :update]

  def index
    respond_with(@time_entries)
  end

  def new
    if params[:date]
      @time_entry.start_date = params[:date]
    end
  end

  def edit
  end

  def create
    adjust_timer_day_boundary
    @time_entry.save
    respond_with @time_entry, location: default_return_location
  end

  def update
    @time_entry.update_attributes(params[:time_entry])
    adjust_timer_day_boundary
    @time_entry.save
    respond_with @time_entry, location: default_return_location
  end

  def destroy
    @time_entry.destroy
    respond_with @time_entry, location: default_return_location
  end

  private
  def adjust_timer_day_boundary
    if !@time_entry.timer? && @time_entry.starts && @time_entry.ends <= @time_entry.starts
      @time_entry.end_date = @time_entry.start_date + 1
    end
  end

  def set_end_date
    if params[:time_entry][:end_date].blank? && params[:time_entry][:end_time].present?
      params[:time_entry][:end_date] ||= params[:time_entry][:start_date]
    end
  end

  def default_return_location
    user_time_entries_path(@user)
  end

  def load_time_types
    @time_types = TimeType.work
  end
end
