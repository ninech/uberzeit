class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper
  
  if Rails.env.development?
    before_filter :local_authenticate
  else
    before_filter :cas_authenticate
  end

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
end
