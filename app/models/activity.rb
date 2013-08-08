# == Schema Information
#
# Table name: activities
#
#  id                :integer          not null, primary key
#  activity_type_id  :integer
#  user_id           :integer
#  date              :date
#  duration          :integer
#  description       :text
#  customer_id       :integer
#  project_id        :integer
#  redmine_ticket_id :integer
#  otrs_ticket_id    :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Activity < ActiveRecord::Base

  acts_as_paranoid

  default_scope order(:customer_id, :date)

  belongs_to :activity_type, with_deleted: true
  belongs_to :project, with_deleted: true
  belongs_to :user, with_deleted: true
  belongs_to :customer, with_deleted: true

  attr_accessible :customer_id, :date, :description, :duration, :otrs_ticket_id, :project_id, :redmine_ticket_id, :activity_type_id, :user_id, :billable

  validates_presence_of :user, :activity_type, :date, :duration, :customer_id
  validates_numericality_of :duration, greater_than: 0

  scope :by_user, ->(user) { where(user_id: user)}
  scope :by_redmine_ticket, ->(redmine_ticket_id) { where(redmine_ticket_id: redmine_ticket_id) }
  scope :by_otrs_ticket, ->(otrs_ticket_id) { where(otrs_ticket_id: otrs_ticket_id) }

  def billable?
    !!billable
  end

end
