class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper

  before_filter :cors
  around_filter :set_time_zone
  before_filter :ensure_logged_in
  after_filter  :set_csrf_cookie_for_cors

  if Rails.env.staging? || Rails.env.production?
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404 # TODO: DOES NOT WITH RAILS 3.2 ANYMORE! Workarounds are ugly...
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404 # To prevent Rails 3.2.8 deprecation warnings
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end
  rescue_from CanCan::AccessDenied, with: :render_403

  layout proc { |controller| controller.request.xhr? ? nil : 'application' }

  def cors
    return unless request.headers["HTTP_ORIGIN"]
    headers['Access-Control-Allow-Origin']  = request.headers['HTTP_ORIGIN'] if UberZeit::Config.ubertrack_hosts.include?(request.headers['ORIGIN'])
    headers['Access-Control-Allow-Methods'] = %w{GET POST PUT DELETE}.join(',')
    headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')
    headers['Access-Control-Allow-Credentials'] = 'true'
    headers['Access-Control-Max-Age'] = '0'
    head(:ok) if request.request_method == 'OPTIONS'
  end

  protected

  def verified_request?
    super || (!form_authenticity_token.blank? && form_authenticity_token == cookies['XSRF-TOKEN'])
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

  def set_csrf_cookie_for_cors
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

end
