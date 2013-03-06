module SessionsHelper
  include AfterLoginHelper

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def sign_in(user)
    session[:user_id] = user.id

    after_login(user)
  end

  def signed_in?
    current_user != nil
  end
end
