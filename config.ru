# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

use Rack::Cors, logger: Rails.logger do
  allow do
    origins(*UberZeit::Config.ubertrack_hosts)
    resource '*', headers: :any, methods: [:get, :post, :delete], credentials: true, max_age: 0
  end
end

run Uberzeit::Application
