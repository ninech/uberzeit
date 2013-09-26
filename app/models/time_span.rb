class TimeSpan < ActiveRecord::Base

  belongs_to :user
  belongs_to :time_type
  belongs_to :time_spanable, polymorphic: true

  attr_accessible :date, :duration, :duration_bonus, :duration_days

  def duration=(value)
    write_attribute :duration_in_work_days, value.to_work_days
    super
  end

  def duration_in_work_days=(value)
    write_attribute :duration, value.work_days
    super
  end

end
