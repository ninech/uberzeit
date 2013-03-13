class TimeEntry < ActiveRecord::Base
  include CommonEntry

  attr_accessible :start_time, :end_time

  before_validation :round_times

  validates_presence_of :start_time, :end_time

  validates_datetime :start_time
  validates_datetime :end_time, after: :start_time

  def self.nonrecurring_entries_in_range(range)
    time_range = range.to_time_range
    nonrecurring_entries.find(:all, conditions: ['(start_time < ? AND end_time > ?)', time_range.max, time_range.min])
  end

  def starts
    start_time
  end

  def ends
    end_time
  end

  def occurrences_as_time_ranges(date_or_range)
    occurrences(date_or_range).collect { |start_time| range_for_other_start_time(start_time) }
  end

  private

  def round_times
    self.start_time = start_time.round unless start_time.nil?
    self.end_time = end_time.round unless end_time.nil?
  end

  def range_for_other_start_time(other_start_time)
    other_start_time = other_start_time.to_time
    (other_start_time..other_start_time+duration)
  end
end
