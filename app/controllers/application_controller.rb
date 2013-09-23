class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper

  around_filter :set_time_zone
  before_filter :ensure_logged_in

  layout proc { |controller| controller.request.xhr? ? nil : 'application' }

  private

  def ensure_logged_in
    if current_user.nil?
      redirect_to new_session_path
    end
  end

  # U Can't touch this! Rails may leak zone to other request from another user in same thread
  # http://ilikestuffblog.com/2011/02/03/how-to-set-a-time-zone-for-each-request-in-rails/
  def set_time_zone
    old_time_zone = Time.zone
    Time.zone = current_user.time_zone if signed_in?
    yield
  ensure
    Time.zone = old_time_zone
  end

end
