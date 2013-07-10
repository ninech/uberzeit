class API::Resources::TimeTypes < Grape::API
  resource :time_types do
    desc 'Lists all available time types'
    get do
      present TimeType.all, with: API::Entities::TimeType
    end
  end
end

