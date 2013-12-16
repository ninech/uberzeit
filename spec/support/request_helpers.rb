module RequestHelpers
  def login(user)
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({
      provider: 'password',
      uid: user.email
    })
    visit new_session_path
    fill_in 'E-Mail', with: user.email
    fill_in 'Passwort', with: '******'
    click_on 'Login'
  end

  def app_auth_get(url, params = {}, env = {})
    get url, params, env.merge({ 'SSL_CLIENT_VERIFY' => 'SUCCESS' })
  end
end
