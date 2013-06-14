class API::Entities::Activity < Grape::Entity
  expose :id
  expose :activity_type_id
  expose :duration
  expose :date
  expose :description
  expose :customer_id
  expose :project_id
  expose :redmine_ticket_id
  expose :otrs_ticket_id
  expose :user_id

  expose :user, using: API::Entities::User, if: ->(activity, options) do
    options[:embed] && options[:embed].include?('user')
  end

  expose :activity_type, using: API::Entities::ActivityType
end
