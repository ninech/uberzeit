class API::User < Grape::API
  extend API::Shared::ExceptionHandling

  version 'v1', using: :header, vendor: 'nine.ch'

  format :json

  #
  # Authentication
  #
  use Warden::Manager do |manager|
    manager.default_strategies :token, :session
    manager.failure_app = ::API
  end

  before do
    env['warden'].authenticate
    ensure_authentication! # authenticate all api requests
    Time.zone = current_user.time_zone if current_user.time_zone
  end

  helpers do
    def current_user
      env['warden'].user
    end

    def ensure_authentication!
      error!('401 Unauthorized', 401) unless current_user
    end
  end

  #
  # Exceptions
  #
  include API::Shared::ExceptionHandling

  #
  # Resources
  #
  mount API::User::Resources::ActivityTypes
  mount API::User::Resources::Activities
  mount API::User::Resources::Timer
  mount API::User::Resources::TimeTypes
  mount API::User::Resources::Absences

  mount API::User::Resources::Customers

  #
  # Ping? Pong!
  #
  desc 'Ping? Pong!'
  get :ping do
    { pong: Time.now }
  end

  #
  # Documentation
  #
  add_swagger_documentation api_version: 'v1',
                            base_path: lambda { |request| "#{request.base_url}/api" },
                            hide_documentation_path: true
end

