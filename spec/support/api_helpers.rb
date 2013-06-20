module ApiHelpers
  def auth_headers
    { 'HTTP_X_AUTH_TOKEN' => api_user.authentication_token }
  end

  def auth_post(route, params = {})
    post route, params, auth_headers
  end

  def auth_get(route, params = {})
    get route, params, auth_headers
  end
end
