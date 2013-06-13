class API::Resources::ActivityTypes < Grape::API
  resource :activity_types do
    desc 'Lists all available activity types'
    get do
      present ActivityType.all, with: API::Entities::ActivityType
    end
  end
end

