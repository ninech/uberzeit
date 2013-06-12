class API < Grape::API
  module Resources
    class ActivityTypes < Grape::API

      resource :activity_types do
        desc 'Lists all available activity types'
        get do
          present ActivityType.all, with: Entities::ActivityType
        end
      end

    end
  end
end

