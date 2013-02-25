class TimeType < ActiveRecord::Base
  acts_as_paranoid
  validates_as_paranoid

  attr_accessible :is_onduty, :is_vacation, :is_work, :name

  validates_uniqueness_of_without_deleted :name

  def to_s
    name
  end
end