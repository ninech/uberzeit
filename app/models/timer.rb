class Timer < ActiveRecord::Base
  before_save :check_active_timers_on_same_date
  belongs_to :time_sheet
  belongs_to :time_type
  attr_accessible :time_type_id, :from_time, :start_date

  scope :on, lambda { |date| range = date.to_range.to_time_range; { conditions: ['(start_time >= ? AND start_time <= ?)', range.min, range.max] } }
  scope :others, lambda { |date| range = date.to_range.to_time_range; { conditions: ['(start_time < ? OR start_time > ?)', range.min, range.max] } }

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
    (start_time..Time.parse("#{start_date} #{Time.now.strftime('%H:%M')}")).duration
  end

  def stop
    time_entry = TimeEntry.new
    time_entry.time_sheet = time_sheet
    time_entry.time_type  = time_type
    time_entry.start_time = start_time
    time_entry.end_time   = Time.parse("#{start_date} #{Time.now.strftime('%H:%M')}")
    time_entry.save

    destroy
  end

  private
  def check_active_timers_on_same_date
    timers = self.time_sheet.timers.on(self.start_date.to_date)
    unless timers.empty?
      timers.first.stop
    end
  end

end
