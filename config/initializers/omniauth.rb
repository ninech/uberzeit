Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :developer, :fields => [:email], :uid_field => :email
    #provider :password, login_field: :email, user_model: User
  end
  provider :cas, url: Uberzeit::Application.config.cas_url, disable_ssl_verification: false
end

OmniAuth.config.logger = Rails.logger
