class TimeSpan < ActiveRecord::Base

  belongs_to :user
  belongs_to :time_type
  belongs_to :time_spanable, polymorphic: true

  attr_accessible :date, :duration, :duration_bonus, :duration_days

  def duration=(value)
    self.duration_days = value.to_f / 60 / 60 / 24
    super
  end

end
