Gaffe.configure do |config|
  config.errors_controller = ErrorsController
end
Gaffe.enable!
# Uncomment for development
#Rails.application.config.consider_all_requests_local = false
