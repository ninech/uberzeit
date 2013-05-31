Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :developer, :fields => [:email], :uid_field => :email
  end
  if Rails.env.production?
    provider :cas, url: 'https://sso.nine.ch/login', disable_ssl_verification: false
  else
    provider :cas, url: "https://sso-#{Rails.env}.nine.ch/login", disable_ssl_verification: false
  end
end

OmniAuth.config.logger = Rails.logger
