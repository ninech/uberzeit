class Customer < ActiveRecord::Base
  self.primary_key = :id

  attr_accessible :id, :name

  validates_presence_of :id
end
