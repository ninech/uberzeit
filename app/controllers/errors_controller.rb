class ErrorsController < ApplicationController
  include Gaffe::Errors
  skip_before_filter :ensure_logged_in

  before_filter :notify_airbrake_if_needed

  def notify_airbrake_if_needed
    notify_airbrake(@exception) if @status_code >= 500 && self.respond_to?(:notify_airbrake)
  end
end
