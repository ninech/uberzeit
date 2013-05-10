class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper

  around_filter :set_time_zone
  before_filter :ensure_logged_in

  unless Rails.env.test?
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404 # To prevent Rails 3.2.8 deprecation warnings
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from CanCan::AccessDenied, with: :render_403
  end

  private

  def render_exception(status = 500, exception)
    notify_airbrake(exception) if status >= 500
    @exception = exception
    @status = status
    render template: "errors/error", formats: [:html], layout: 'application', status: @status
  end

  def render_403(exception = nil)
    render_exception(403, exception)
  end

  def render_404(exception = nil)
    render_exception(404, exception)
  end

  def render_500(exception = nil)
    render_exception(500, exception)
  end

  def ensure_logged_in
    if current_user.nil?
      raise CanCan::AccessDenied, I18n.t(:not_logged_in)
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
