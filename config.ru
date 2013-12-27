# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

use Rack::Cors, logger: Rails.logger do
  if UberZeit.config.ubertrack_hosts.present?
    allow do
      origins(*UberZeit.config.ubertrack_hosts.values)
      resource '*', headers: :any, methods: [:get, :post, :delete], credentials: true, max_age: 0
    end
  end
end

run Uberzeit::Application
