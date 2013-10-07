class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper

  before_filter :ensure_logged_in

  layout proc { |controller| controller.request.xhr? ? nil : 'application' }

  private

  def ensure_logged_in
    if current_user.nil?
      redirect_to new_session_path
    end
  end

end
