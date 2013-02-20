module SessionsHelper
  include AfterLoginHelper
  
  def current_user
    if !session || !session['user']
      nil
    else
      @current_user ||= User.find_by_ldap_id(session['user'])
    end
  end

  def sign_in(id)
    session['user'] = id

    after_login(id)
  end

  def signed_in?
    current_user != nil
  end
end
