class API::App < Grape::API
  version 'v1', using: :header, vendor: 'nine.ch'

  format :json

  #
  # Authentication
  #
  before do
    ensure_authentication!
  end

  helpers do
    def ensure_authentication!
      error!('401 Unathorized', 401) unless request.env['SSL_CLIENT_VERIFY'] == 'SUCCESS' or Rails.env.development?
    end
  end

  #
  # Resources
  #
  mount API::App::Resources::Absences

  desc 'Ping? Pong!'
  get :ping do
    { pong: Time.now }
  end
end
