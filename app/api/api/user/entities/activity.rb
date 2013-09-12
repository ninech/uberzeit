class API::User::Entities::Activity < Grape::Entity
  expose :id
  expose :duration
  expose :date
  expose :description
  expose :customer_id
  expose :project_id
  expose :redmine_ticket_id
  expose :otrs_ticket_id
  expose :user_id

  expose :updated_at
  expose :created_at

  expose :user, using: API::User::Entities::User, if: ->(activity, options) do
    options[:embed] && options[:embed].include?('user')
  end

  expose :project, using: API::User::Entities::Project, if: ->(activity, options) do
    options[:embed] && options[:embed].include?('project')
  end

  expose :activity_type, using: API::User::Entities::ActivityType
end
