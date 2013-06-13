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
end
