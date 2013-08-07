# == Schema Information
#
# Table name: customers
#
#  id         :integer          primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Customer < ActiveRecord::Base
  has_many :projects
  has_many :activities

  self.primary_key = :id

  attr_accessible :id, :name

  validates_presence_of :id

  def display_name
    "#{id}: #{name}"
  end

  def to_s
    display_name
  end
end
