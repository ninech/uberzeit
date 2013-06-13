class Customer < ActiveRecord::Base
  attr_accessible :id, :name

  validates_presence_of :id, :name
end
