# == Schema Information
#
# Table name: time_entries
#
#  id           :integer          not null, primary key
#  time_type_id :integer
#  starts       :datetime
#  ends         :datetime
#  deleted_at   :datetime
#  user_id      :integer
#

class TimeEntry < ActiveRecord::Base

  acts_as_paranoid

  default_scope order(:starts)

  belongs_to :user
  belongs_to :time_type, with_deleted: true
  has_many :time_spans, as: :time_spanable, dependent: :destroy

  attr_accessible :user_id, :time_type_id, :type
  attr_accessible :start_time, :start_date, :end_date, :end_time

  validates_presence_of :user, :time_type
  validates_presence_of :starts, :start_time, :start_date
  validates_presence_of :ends, unless: :timer?
  validates_datetime :starts
  validates_datetime :ends, after: :starts, unless: :timer?
  validate :must_be_only_timer_on_date, if: :timer?

  scope :on, lambda { |date| range = date.to_range.to_time_range; { conditions: ['(starts >= ? AND starts <= ?)', range.min, range.max] } }
  scope :others, lambda { |date| range = date.to_range.to_time_range; { conditions: ['(starts < ? OR starts > ?)', range.min, range.max] } }

  scope :timers_only, where(ends: nil)
  scope :except_timers, where('time_entries.ends IS NOT NULL')

  before_validation :round_times
  after_save :update_or_create_time_span


  def self.entries_in_range(range)
    time_range = range.to_time_range
    find(:all, conditions: ['(starts < ? AND ends > ?)', time_range.max, time_range.min])
  end

  def self.timers_in_range(range)
    timers_only.select { |timer| range.intersect(timer.range) }
  end

  def self.timers_not_in_range(range)
    timers_only.reject { |timer| range.intersect(timer.range) }
  end

  def timer?
    ends.blank?
  end

  def duration(date_or_range = nil)
    duration_range =  if date_or_range.nil?
                        range
                      else
                        range.intersect(date_or_range.to_range)
                      end
    duration_range.duration
  end

  def range
    if timer?
      (starts..[Time.current, starts].max)
    else
      (starts..ends)
    end
  end

  def occurrences(date_or_range)
    [starts]
  end


  def start_date
    return @start_date.to_date if @start_date
    (starts || Date.current).to_date
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
    self.ends = date_and_time_to_datetime_format((end_date || start_date), value)
  end

  def occurrences_as_time_ranges(date_or_range)
    occurrences(date_or_range).collect { |start_time| range_for_other_start_time(start_time) }
  end

  def stop
    self.ends = Time.current
    save
  end

  def update_or_create_time_span
    time_spans.destroy_all
    return if ends.nil?
    (starts.to_date..ends.to_date).each do |date|
      time_span = time_spans.build
      time_span.duration = duration(date)
      time_span.credited_duration = time_type.exclude_from_calculation? ? 0 : time_span.duration
      time_span.user = user
      time_span.time_type = time_type
      time_span.date = date
      time_span.duration_bonus = UberZeit::BonusCalculators.use(time_type.bonus_calculator, self).result
      time_span.save!
    end
  end

  private

  def must_be_only_timer_on_date
    if other_timers_on_same_date.any?
      errors.add(:start_date, :timer_exists_on_date_already)
    end
  end

  def other_timers_on_same_date
    if user
      user.time_entries.timers_only.on(start_date) - [self]
    else
      []
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

end
