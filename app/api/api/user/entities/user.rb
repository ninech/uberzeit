class API::User::Entities::User < Grape::Entity
  expose :id
  expose :name do |user, options|
    [user.given_name, user.name].compact.join(' ')
  end
end
