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
      authenticate_or_request_with_http_basic "Username = LDAP Usermail" do |usermail, password|
        person = Person.find_by_mail(usermail)
        if password == 'nineuberzeit' && person
          LdapSync.sync_person(person.id)
          
          session[:cas] = {}
          session[:cas]['user'] = person.id
        end
      end
    end
  end

  def hello_world
    render :text => 'Hello World'
  end

  def cas_authenticate
    raise NotImplementedError
  end
end
