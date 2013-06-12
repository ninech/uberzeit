class API < Grape::API
  module Entities
    class ActivityType < Grape::Entity
      expose :id
      expose :name
    end
  end
end
