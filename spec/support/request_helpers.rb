module RequestHelpers
  def login(user)
    user.update_attribute(:uid, 'user1')
    visit root_path
  end

  def auth_get(url, params = {}, env = {})
    get url, params, env.merge({ 'SSL_CLIENT_VERIFY' => 'SUCCESS' })
  end
end
