Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :developer unless Rails.env.production?
  provider :cas, url: 'https://sso-staging.nine.ch/login', disable_ssl_verification: false
end

OmniAuth.config.logger = Rails.logger
