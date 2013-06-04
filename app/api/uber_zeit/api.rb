require_relative 'validators/time_type_for_timer'

module UberZeit
  class API < Grape::API
    prefix 'api'

    format :json

    version 'v1', using: :header, vendor: 'nine.ch'

    http_basic do |username, password|
      password = 'apiaccess42'
    end

    before do
      authenticate! # authenticate all api requests
      Time.zone = current_user.time_zone if current_user.time_zone
    end

    helpers do
      def current_user
        @current_user ||= User.find_by_uid(request.env['REMOTE_USER'])
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    # more verbose validation exception response
    rescue_from Grape::Exceptions::Validation do |e|
      Rack::Response.new({
        'status' => e.status,
        'message' => e.message,
        'param' => e.param
      }.to_json, e.status)
    end

    get :hello_world do
      { hello: 'world' }
    end

    resource :timers do
      params do
        requires :time_type_id, type: Integer, time_type_for_timer: true, desc: 'A time type ID.'
        optional :start_date, type: String, regexp: /\d{4}-\d{2}-\d{2}/, desc: 'A start date in the format YYYY-MM-DD. Defaults to current date.'
        optional :start_time, type: String, regexp: /\d{2}:\d{2}/,  desc: 'A start time in the format HH:MM. Defaults to current time.'
      end

      desc 'Starts a timer.'
      post do
        start_date = params[:start_date] || Date.current
        start_time = params[:start_time] || Time.current.strftime('%H:%M')
        time_type_id = params[:time_type_id]

        TimeEntry.create!(
          time_sheet_id: current_user.current_time_sheet.id,
          time_type_id: time_type_id,
          start_date: start_date,
          start_time: start_time,
        )
      end
    end
  end
end
