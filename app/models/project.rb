class Project < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :customer, primary_key: :id

  attr_accessible :name, :customer, :customer_id

  validates_presence_of :customer, :name

  scope :by_customer, ->(user) { where(customer_id: user)}
end
