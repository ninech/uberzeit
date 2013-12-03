class API::User::Entities::Customer < Grape::Entity
  expose :id
  expose :number
  expose :name
  expose :display_name
end
