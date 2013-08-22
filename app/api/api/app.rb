class API::App < Grape::API
  version 'v1', using: :header, vendor: 'nine.ch'

  format :json

  mount API::Shared::Resources::Customers

  desc 'Ping? Pong!'
  get :ping do
    { pong: Time.now }
  end
end
