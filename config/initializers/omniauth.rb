Rails.application.config.middleware.use OmniAuth::Builder do
  (UberZeit.config.auth_providers || []).each do |provider_options|
    provider_options.deep_symbolize_keys!
    provider provider_options[:provider], provider_options.except(:provider)
  end
#  provider :cas, url: Uberzeit::Application.config.cas_url, disable_ssl_verification: false
end

OmniAuth.config.logger = Rails.logger
