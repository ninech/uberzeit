class ActivitiesController < ApplicationController

  include Concerns::WeekView
  include ActivitiesHelper

  respond_to :html, :json, :js

  # TODO: switch to strong parameters
  before_filter :remove_reviewed_attribute, only: [:update, :create], unless: :can_review_an_activity?

  load_and_authorize_resource :user
  load_and_authorize_resource :activity, through: :user

  before_filter :load_day, :prepare_week_view, :prepare_weekday_sums, only: :index
  before_filter :prepare_form, only: [:edit, :update, :new, :create]
  before_filter :parse_duration_to_seconds, only: [:update, :create]

  def new
    if params[:date]
      @activity.date = params[:date]
    end
    last_activity = @user.activities.order(:created_at).last
    @activity.activity_type ||= last_activity.activity_type if last_activity
  end

  def edit
  end

  def index
    @activities = @activities.where(date: @day)
    @week_total = @user.activities.where(date: @week).sum(:duration)
  end

  def destroy
    @activity.destroy
    respond_with @activity, location: show_date_user_activities_path(@user, date: @activity.date)
  end

  def update
    @activity.update_attributes(activity_params)
    respond_with @activity, location: show_date_user_activities_path(@user, date: @activity.date)
  end

  def create
    @activity.update_attributes(activity_params)
    respond_with @activity, location: show_date_user_activities_path(@activity.user, date: @activity.date || Time.now)
  end

  private

  def activity_params
    (params[:activity] || {}).merge(user_id: @user.id)
  end

  def parse_duration_to_seconds
    if params[:activity] && params[:activity][:duration]
      duration = params[:activity][:duration]
      duration = case
                 when duration =~ /\A\d{1,3}\z/
                   duration.to_i * 60
                 when duration.include?('.')
                   duration.to_f.hours
                 when duration.include?(':')
                   UberZeit.hhmm_in_duration duration
                 end
      params[:activity][:duration] = duration
    end
  end

  def prepare_weekday_sums
    @weekday_sums = {}
    @weekdays.each do |weekday|
      @weekday_sums[weekday] = @user.activities.where(date: weekday).sum(:duration)
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

  def remove_reviewed_attribute
    params[:activity].delete(:reviewed)
  end

  def can_review_an_activity?
    can? :review, @activity || Activity
  end
end
