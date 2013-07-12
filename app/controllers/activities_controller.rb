class ActivitiesController < ApplicationController

  include DateHelper

  load_and_authorize_resource :user
  load_and_authorize_resource :activity, through: :user

  before_filter :load_day

  def index
    @activities = @activities.where(date: @day)
  end
end
