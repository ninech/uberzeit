class Activity < ActiveRecord::Base
  belongs_to :activity_type
  belongs_to :user

  attr_accessible :customer_id, :date, :description, :duration, :otrs_ticket_id, :project_id, :redmine_ticket_id, :activity_type_id, :user_id

  validates_presence_of :user, :activity_type, :date, :duration

  scope :by_user, ->(user) { where(user_id: user)}
  scope :by_redmine_ticket, ->(redmine_ticket_id) { where(redmine_ticket_id: redmine_ticket_id) }
end
