module ApiHelpers
  def headers
    {
      'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(api_user.uid, 'apiaccess42'),
      'HTTP_ACCEPT' => 'application/vnd.nine.ch-v1+json'
    }
  end

  def auth_post(route, params = {})
    post route, params, headers
  end

  def auth_get(route, params = {})
    get route, params, headers
  end
end
