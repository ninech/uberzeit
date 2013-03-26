Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :developer, :fields => [:uid], :uid_field => :uid
  end
  provider :cas, url: 'https://sso-staging.nine.ch/login', disable_ssl_verification: false
end

OmniAuth.config.logger = Rails.logger
