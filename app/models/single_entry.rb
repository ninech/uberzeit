class SingleEntry < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type
  attr_accessible :end_time, :start_time, :time_type_id

  validates_presence_of :time_type, :time_sheet, :start_time

  validates_datetime :start_time
  validates_datetime :end_time, after: :start_time

  before_validation :round_times

  # http://stackoverflow.com/questions/143552/comparing-date-ranges
  scope :between, lambda { |starts, ends| { conditions: ['start_time < ? AND end_time > ?', ends, starts] } }
  scope :work, joins: :time_type, conditions: ['is_work = ?', true]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]
  scope :onduty, joins: :time_type, conditions: ['is_onduty = ?', true]

  def range_for(date_or_range)
    range_range = date_or_range.to_range
    
    range.intersect(range_range)
  end

  def duration_for(date_or_range)
    intersection = range_for(date_or_range)
    duration = intersection.nil? ? 0 : intersection.duration
    duration
  end

  def duration
    return 0 if start_time.nil? or end_time.nil?
    (end_time - start_time).to_i
  end

  def range
    (start_time..end_time)
  end

  def whole_day?
    duration == 1.day
  end

  private

  def round_times
    self.start_time = self.start_time.round
    self.end_time = self.end_time.round
  end
end
