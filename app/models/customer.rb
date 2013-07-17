class Customer < ActiveRecord::Base
  has_many :projects

  self.primary_key = :id

  attr_accessible :id, :name

  validates_presence_of :id

  def display_name
    "#{id}: #{name}"
  end
end
