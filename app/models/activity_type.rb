# == Schema Information
#
# Table name: activity_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class ActivityType < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :name

  has_many :activities

  validates :name, presence: true

  default_scope order(:name)
end
