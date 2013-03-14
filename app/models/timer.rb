class Timer < ActiveRecord::Base
  belongs_to :time_sheet
  belongs_to :time_type
  attr_accessible :time_type_id, :from_time, :start_date

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

  def to_time
    nil
  end

  def duration
    (start_time..Time.current).duration
  end

  def stop
    time_entry = TimeEntry.new
    time_entry.time_sheet = time_sheet
    time_entry.time_type  = time_type
    time_entry.start_time = start_time
    time_entry.end_time   = Time.current
    time_entry.save

    destroy
  end
end
