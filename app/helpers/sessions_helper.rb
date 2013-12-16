module SessionsHelper
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session[:user_id] = nil
  end

  def signed_in?
    current_user != nil
  end

  def all_auth_providers
    UberZeit.config.auth_providers.collect { |config| config.with_indifferent_access }
  end

  def other_auth_providers
    @other_auth_providers ||= all_auth_providers.reject { |config| config[:provider] == 'password' }
  end

  def password_auth_provider?
    all_auth_providers.any? { |config| config[:provider] == 'password' }
  end
end
