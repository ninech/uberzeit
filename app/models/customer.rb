class Customer < ActiveRecord::Base
  set_primary_key :id

  attr_accessible :id, :name

  validates_presence_of :id
end
