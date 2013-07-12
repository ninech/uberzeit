class ActivitiesController < ApplicationController

  include WeekViewHelper
  include ActivitiesHelper

  load_and_authorize_resource :user
  load_and_authorize_resource :activity, through: :user

  before_filter :load_day, :load_time_sheet, :prepare_week_view

  def index
    @activities = @activities.where(date: @day)
  end

  private
  def load_time_sheet
    @time_sheet = @user.current_time_sheet
  end
end
