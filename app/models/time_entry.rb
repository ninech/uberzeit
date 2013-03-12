class TimeEntry < ActiveRecord::Base
  include CommonEntry

  attr_accessible :start_time, :end_time

  before_validation :round_times

  validates_presence_of :start_time, :end_time

  validates_datetime :start_time
  validates_datetime :end_time, after: :start_time

  # http://stackoverflow.com/questions/143552/comparing-date-ranges
  scope :between, lambda { |between_range|
    between_time_range = between_range.to_time_range
    { conditions: ['(start_time < ? AND end_time > ?)', between_time_range.max, between_time_range.min] }
  }

  def self.to_chunks
    scoped.collect { |time_entry| TimeChunk.new(range: time_entry.range, time_type: time_entry.time_type, parent: time_entry) }
  end

  def starts
    start_time
  end

  def ends
    end_time
  end

  private

  def round_times
    self.start_time = start_time.round unless start_time.nil?
    self.end_time = end_time.round unless end_time.nil?
  end
end
