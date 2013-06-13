require_relative 'api/validators/time_type_for_timer'

class API < Grape::API
  version 'v1', using: :header, vendor: 'nine.ch'

  format :json

  #
  # Authentication
  #
  http_basic do |username, password|
    password = 'apiaccess42'
  end

  before do
    authenticate! # authenticate all api requests
    Time.zone = current_user.time_zone if current_user.time_zone
  end

  helpers do
    def current_user
      @current_user ||= User.find_by_id(request.env['rack.session']['user_id']) # session
      @current_user ||= User.find_by_uid(request.env['REMOTE_USER']) # http basic
    end

    def authenticate!
      error!('401 Unauthorized', 401) unless current_user
    end
  end

  #
  # Exceptions
  #
  rescue_from Grape::Exceptions::Validation do |e|
    Rack::Response.new({
      'status' => e.status,
      'message' => e.message,
      'param' => e.param
    }.to_json, e.status)
  end

  #
  # Resources
  #
  mount API::Resources::ActivityTypes
  mount API::Resources::Activities
  mount API::Resources::Timers
  mount API::Resources::Customers

end
