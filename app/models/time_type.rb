class TimeType < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :is_onduty, :is_vacation, :is_work, :name

  def to_s
    name
  end
end
