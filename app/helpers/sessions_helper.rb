module SessionsHelper
  def current_user
    if !session[:cas] || !session[:cas]['user']
      nil
    else
      @current ||= session[:cas]['user']
      #@current_user ||= User.find_by_ldap_id(session[:cas]['user'])
    end
  end

  def signed_in?
    current_user != nil
  end
end
