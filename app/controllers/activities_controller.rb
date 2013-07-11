class ActivitiesController < ApplicationController

  load_and_authorize_resource :user
  load_and_authorize_resource :activity, through: :user

  def index
  end
end
