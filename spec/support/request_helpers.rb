module RequestHelpers
  def login(user)
    user.update_attribute(:email, 'user1@example.com')
    visit root_path
  end

  def app_auth_get(url, params = {}, env = {})
    get url, params, env.merge({ 'SSL_CLIENT_VERIFY' => 'SUCCESS' })
  end
end
