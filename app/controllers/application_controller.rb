class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper

  before_filter :set_locale
  before_filter :ensure_logged_in

  layout proc { |controller| controller.request.xhr? ? nil : 'application' }

  private

  def ensure_logged_in
    if current_user.nil?
      redirect_to new_session_path
    else
      unless current_user.active?
        render text: 'Account deactivated', status: 401
      end
    end
  end

  def set_locale
    I18n.locale = session[:locale] || extract_locale_from_accept_language_header
  end

  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      http_accept_language.compatible_language_from(I18n.available_locales.collect(&:to_s))
    else
      I18n.default_locale
    end
  end

end
