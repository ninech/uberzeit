class ActivityType < ActiveRecord::Base
  attr_accessible :name

  has_many :activities

  validates :name, presence: true

end
