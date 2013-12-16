Rails.application.config.middleware.use OmniAuth::Builder do
  (UberZeit.config.auth_providers || []).each do |provider_options|
    provider_options.deep_symbolize_keys!
    provider provider_options[:provider], provider_options.except(:provider)
  end
end

OmniAuth.config.logger = Rails.logger
