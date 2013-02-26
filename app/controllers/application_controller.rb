class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper
  
  if Rails.env.development?
    before_filter :local_authenticate
  else
    before_filter :cas_authenticate
  end

  around_filter :set_time_zone

  private

  def local_authenticate
    unless signed_in?
      authenticate_or_request_with_http_basic "Username = LDAP Username" do |username, password|
        if password == 'nineuberzeit' && Person.find(username)
          sign_in(username)
        end
      end
    end
  end

  def cas_authenticate
    unless signed_in?
      if session[:cas].nil? || session[:cas]['user'].nil?
        # 401 redirects to SSO
        render :status => 401, text: 'CAS Auth required' 
      else
        person = Person.find_by_mail(session[:cas]['user'])
        sign_in(person.id)
      end
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
