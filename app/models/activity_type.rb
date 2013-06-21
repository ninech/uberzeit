class ActivityType < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :name

  has_many :activities

  validates :name, presence: true

end
