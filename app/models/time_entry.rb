class TimeEntry < ActiveRecord::Base
  include CommonEntry

  attr_accessible :start_time, :end_time, :start_date, :end_date, :from_time, :to_time

  validates_presence_of :start_time, :end_time

  validates_datetime :start_time
  validates_datetime :end_time, after: :start_time

  before_validation :round_times

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



  private

  def round_times
    self.start_time = start_time.round unless start_time.nil?
    self.end_time = end_time.round unless end_time.nil?
  end
end
