class ActivitiesController < ApplicationController

  include WeekViewHelper
  include ActivitiesHelper

  respond_to :html

  load_and_authorize_resource :user
  load_and_authorize_resource :activity, through: :user

  before_filter :load_day, :load_time_sheet, :prepare_week_view, only: :index
  before_filter :prepare_form, only: [:edit, :update]

  def index
    @activities = @activities.where(date: @day)
    week = @day.at_beginning_of_week..@day.at_end_of_week
    @week_total = @user.activities.where(date: week).sum(:duration)
  end

  def destroy
    @activity.destroy
    respond_with @activity, location: show_date_user_activities_path(@user, date: @activity.date)
  end

  def edit
  end

  def update
    data = params[:activity]
    data[:duration] = UberZeit.hhmm_in_duration(data[:duration])
    @activity.update_attributes(data)
    respond_with @activity, location: show_date_user_activities_path(@user, date: @activity.date)
  end

  private
  def load_time_sheet
    @time_sheet = @user.current_time_sheet
  end

  def prepare_form
    @customers = Customer.all
    @projects = @activity.customer.projects.to_a
    if @projects
      @projects.unshift OpenStruct.new(id: '', name: '-')
    end
    @activity_types = ActivityType.all
  end
end
