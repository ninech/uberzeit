require_relative 'api/validators/time_type_for_timer'
require_relative 'api/validators/includes'

class API < Grape::API
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
  collect_validation_errors true

  rescue_from Grape::Exceptions::Validations do |e|
    # convert the errors per attribute into the rails format
    errors_per_param = Hash[e.errors.collect { |error| [error.param, error.message] }]
    Rack::Response.new({
      'status' => 422,
      'message' => e.message,
      'errors' => errors_per_param
    }.to_json, 422)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    Rack::Response.new({
      'status' => 422,
      'message' => e.record.errors.full_messages.to_sentence,
      'errors' => e.record.errors
    }.to_json, 422)
  end

  #
  # Resources
  #
  mount API::Resources::ActivityTypes
  mount API::Resources::Activities
  mount API::Resources::Timers
  mount API::Resources::Customers

  #
  # Ping? Pong!
  #
  get :ping do
    { pong: Time.now }
  end

  #
  # Documentation
  #
  add_swagger_documentation
end
