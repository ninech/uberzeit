class API::User::Entities::TimeType < Grape::Entity
  expose :id
  expose :name
  expose :is_work?, as: :is_work
end
