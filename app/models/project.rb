class Project < ActiveRecord::Base
  belongs_to :customer, primary_key: :id

  attr_accessible :name, :customer

  validates_presence_of :customer, :name

end
