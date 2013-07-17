class API::Entities::Customer < Grape::Entity
  expose :id
  expose :name
  expose :display_name
end
