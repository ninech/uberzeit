OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new({
  :provider => 'cas',
  :uid => 'user1@example.com'
})
OmniAuth.config.test_mode = true
