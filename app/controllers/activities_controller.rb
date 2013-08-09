class ActivitiesController < ApplicationController

  include WeekViewHelper
  include ActivitiesHelper

  respond_to :html, :json, :js

  before_filter :remove_locked_attribute, only: [:update, :create], unless: :can_lock_an_activity?

  load_and_authorize_resource :user
  load_and_authorize_resource :activity, through: :user

  before_filter :load_day, :load_time_sheet, :prepare_week_view, only: :index
  before_filter :prepare_form, only: [:edit, :update, :new, :create]
  before_filter :parse_duration_to_seconds, only: [:update, :create]
  before_filter :extract_customer_id, only: [:update, :create]

  DURATION_IN_MINUTES_REGEX = /\A\d{1,3}\z/

  def new
    if params[:date]
      @activity.date = params[:date]
    end
  end

  def edit
  end

  def index
    @activities = @activities.where(date: @day)
    week = @day.at_beginning_of_week..@day.at_end_of_week
    @week_total = @user.activities.where(date: week).sum(:duration)
  end

  def destroy
    @activity.destroy
    respond_with @activity, location: show_date_user_activities_path(@user, date: @activity.date)
  end

  def update
    @activity.update_attributes(params[:activity])
    respond_with @activity, location: show_date_user_activities_path(@user, date: @activity.date)
  end

  def create
    @activity.update_attributes(params[:activity])
    respond_with @activity, location: show_date_user_activities_path(@user, date: @activity.date || Time.now)
  end

  private
  def parse_duration_to_seconds
    if params[:activity] &&
      duration = params[:activity][:duration]
      if DURATION_IN_MINUTES_REGEX.match duration
        duration = duration.to_i * 60
      elsif duration.include? ':'
        duration = UberZeit.hhmm_in_duration duration
      end
      params[:activity][:duration] = duration
    end
  end

  def load_time_sheet
    @time_sheet = @user.current_time_sheet
  end

  def extract_customer_id
    unless params[:activity][:customer_id].blank?
      match = params[:activity][:customer_id].match(/\d+/)
      match[0] if match
    end
  end

  def prepare_form
    if @activity.customer
      @projects = @activity.customer.projects.to_a
      unless @projects.empty?
        @projects.unshift OpenStruct.new(id: '', name: '-')
      end
    else
      @projects = []
    end
    @activity_types = ActivityType.all
  end

  def remove_locked_attribute
    params[:activity].delete(:locked)
  end

  def can_lock_an_activity?
    can? :lock, @activity || Activity
  end
end
