class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper

  around_filter :set_time_zone

  unless Rails.env.test?
    rescue_from CanCan::AccessDenied do |error|
      flash[:error] = error.message
      redirect_to root_path
    end
  end

  private

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
