# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

class Project < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :customer, primary_key: :id

  attr_accessible :name, :customer, :customer_id

  validates_presence_of :customer, :name

  default_scope order(:name)
  scope :by_customer, ->(user) { where(customer_id: user)}
end
