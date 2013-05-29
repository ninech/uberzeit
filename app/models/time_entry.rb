class TimeEntry < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type, with_deleted: true

  attr_accessible :time_sheet_id, :time_type_id, :type
  attr_accessible :start_time, :start_date, :end_date, :end_time

  validates_presence_of :time_sheet, :time_type
  validates_presence_of :starts, :start_time, :start_date
  validates_presence_of :ends, unless: :timer?
  validates_datetime :starts
  validates_datetime :ends, after: :starts, unless: :timer?

  default_scope order(:starts)
  scope :on, lambda { |date| range = date.to_range.to_time_range; { conditions: ['(starts >= ? AND starts <= ?)', range.min, range.max] } }
  scope :others, lambda { |date| range = date.to_range.to_time_range; { conditions: ['(starts < ? OR starts > ?)', range.min, range.max] } }

  scope :timers_only, where(ends: nil)
  scope :except_timers, where('time_entries.ends IS NOT NULL')


  before_validation :round_times
  before_validation :ensure_ends_is_after_start
  before_create :check_active_timers_on_same_date, if: :timer?


  def self.entries_in_range(range)
    time_range = range.to_time_range
    find(:all, conditions: ['(starts < ? AND ends > ?)', time_range.max, time_range.min])
  end


  def timer?
    ends.blank?
  end

  def duration
    range.duration
  end

  def range
    (starts..(ends || Time.current))
  end

  def occurrences(date_or_range)
    [starts]
  end


  def start_date
    return @start_date.to_date if @start_date
    (starts || Time.current).to_date
  end

  def start_date=(value)
    @start_date = value
    self.starts = date_and_time_to_datetime_format(value, start_time)
  end

  def start_time
    return @start_time if @start_time
    my_starts = (starts || Time.current)
    hour_and_min_to_time_string(my_starts.hour, my_starts.min)
  end

  def start_time=(value)
    @start_time = value
    self.starts = date_and_time_to_datetime_format(start_date, value)
  end


  def end_date
    return nil unless ends
    self.ends.to_date
  end

  def end_date=(value)
    self.ends = date_and_time_to_datetime_format(value, end_time)
  end

  def end_time
    return nil unless ends
    hour_and_min_to_time_string(ends.hour, ends.min)
  end

  def end_time=(value)
    self.ends = date_and_time_to_datetime_format(end_date, value)
  end

  def occurrences_as_time_ranges(date_or_range)
    occurrences(date_or_range).collect { |start_time| range_for_other_start_time(start_time) }
  end

  def stop
    self.ends = Time.current
    save
  end

  private
  def check_active_timers_on_same_date
    timers = time_sheet.time_entries.timers_only.on(self.start_date.to_date)
    unless timers.empty?
      timers.first.stop
    end
  end

  def round_times
    self.starts = starts.round unless starts.nil?
    self.ends = ends.round unless ends.nil?
  end

  def range_for_other_start_time(other_start_time)
    (other_start_time..other_start_time+duration)
  end

  def hour_and_min_to_time_string(hour, min)
    "#{'%02d' % hour}:#{'%02d' % min}"
  end

  def date_and_time_to_datetime_format(date, time)
    "#{date} #{time}:00"
  end

  def ensure_ends_is_after_start

    if ends && starts && ends < starts
      self.ends = starts + 1.day
    end
  end
end
