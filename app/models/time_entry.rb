class TimeEntry < ActiveRecord::Base
  include CommonEntry

  attr_accessible :start_time, :end_time, :start_date, :end_date, :from_time, :to_time

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

  def start_date
    self.start_time ||= Time.now
    self.start_time.to_date.to_s(:db)
  end

  def start_date=(value)
    self.start_time = "#{value} #{self.from_time}:00"
  end

  def from_time
    self.start_time ||= Time.now
    "#{'%02d' % self.start_time.hour}:#{'%02d' % self.start_time.min}"
  end

  def from_time=(value)
    self.start_time = "#{self.start_date} #{value}:00"
  end

  def end_date
    if self.end_time
      return self.end_time.to_date.to_s(:db)
    else
      self.start_date.to_date.to_s(:db)
    end
  end

  def end_date=(value)
    if self.to_time
      self.end_time = "#{value} #{self.to_time}:00"
    else
      self.end_time = "#{value} 00:00:00"
    end
  end

  def to_time
    if self.end_time
     return "#{'%02d' % self.end_time.hour}:#{'%02d' % self.end_time.min}"
    end
  end

  def to_time=(value)
    self.end_time = "#{self.end_date} #{value}:00"
    if self.end_time < self.start_time
      self.end_time = self.end_time + 1.day
    end
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
