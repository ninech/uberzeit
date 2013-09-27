# == Schema Information
#
# Table name: absences
#
#  id              :integer          not null, primary key
#  time_type_id    :integer
#  start_date      :date
#  end_date        :date
#  first_half_day  :boolean          default(TRUE)
#  second_half_day :boolean          default(TRUE)
#  deleted_at      :datetime
#  user_id         :integer
#

class Absence < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :time_type, with_deleted: true
  has_many :time_spans, as: :time_spanable, dependent: :destroy
  has_one :schedule, class_name: :AbsenceSchedule, dependent: :destroy

  default_scope order(:start_date)
  scope :work, joins: :time_type, conditions: ['is_work = ?', true]
  scope :absence, joins: :time_type, conditions: ['is_work = ?', false]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]

  attr_accessible :start_date, :end_date, :first_half_day, :second_half_day, :daypart
  attr_accessible :schedule, :schedule_attributes
  attr_accessible :user_id, :time_type_id, :type

  validates_presence_of :start_date, :end_date
  validates_presence_of :user, :time_type
  after_initialize :set_default_dates

  validates_datetime :start_date
  validates_datetime :end_date, on_or_after: :start_date

  accepts_nested_attributes_for :schedule

  after_save :update_or_create_time_span
  before_validation :build_schedule, unless: :schedule

  def self.nonrecurring_entries_in_range(range)
    date_range = range.to_date_range
    nonrecurring_entries.where('(start_date <= ? AND end_date >= ?)', date_range.max, date_range.min)
  end

  def self.recurring_entries
    # inner join
    scoped.joins(:schedule).where(absence_schedules: {active: true})
  end

  def self.nonrecurring_entries
    # left outer join
    scoped.includes(:schedule).where(absence_schedules: {active: false})
  end

  def self.recurring_entries_in_range(range)
    recurring_entries.collect { |absence| absence if absence.schedule.occurring?(range) }.compact
  end

  def self.entries_in_range(range)
    recurring_entries_in_range(range) + nonrecurring_entries_in_range(range)
  end

  def duration
    range.duration
  end

  def daily_work_duration
    duration = UberZeit::Config[:work_per_day]
    if whole_day?
      duration
    else
      duration * 0.5
    end
  end

  def range
    (starts..ends)
  end

  def recurring?
    schedule && schedule.active?
  end

  def occurrences(date_or_range)
    if recurring?
      schedule.occurrences(date_or_range)
    else
      [starts]
    end
  end

  def set_default_dates
    self.start_date ||= Date.current
    self.end_date ||= Date.current
  end

  def whole_day?
    # true when both or none of the flags is set
    not first_half_day? and not second_half_day?
  end

  def half_day?
    not whole_day?
  end

  def first_half_day?
    !!first_half_day and not !!second_half_day
  end

  def second_half_day?
    !!second_half_day and not !!first_half_day
  end

  def starts
    start_date
  end

  def ends
    end_date
  end

  def daypart
    case
    when whole_day?
      :whole_day
    when first_half_day?
      :first_half_day
    when second_half_day?
      :second_half_day
    end
  end

  def daypart=(value)
    case value.to_sym
    when :whole_day
      self.first_half_day = true
      self.second_half_day = true
    when :first_half_day
      self.first_half_day = true
      self.second_half_day = false
    when :second_half_day
      self.first_half_day = false
      self.second_half_day = true
    end
  end

  def time_range_for_date(date)
    time_start = date.midnight
    time_end = date.midnight + 1.day

    time_end = time_end - 12.hours if first_half_day?
    time_start = time_start + 12.hours if second_half_day?

    (time_start..time_end)
  end

  def num_days
    end_date - start_date
  end

  def occurrences_as_time_ranges(date_or_range)
    # for date entries we have to generate a occurrence range for each day (half days are not continuous)
    occurrences(date_or_range).collect do |start_date|
      date_range = start_date..(start_date+num_days)
      date_range.collect { |day| time_range_for_date(day) }
    end.flatten
  end

  def update_or_create_time_span
    time_spans.destroy_all
    (start_date..end_date).each do |date|
      duration_in_work_days = CalculatePlannedWorkingTime.new(date.to_range, user, fulltime: true).total.to_work_days
      time_span = time_spans.build
      time_span.duration_in_work_days = duration_in_work_days
      time_span.user = user
      time_span.time_type = time_type
      time_span.date = date
      time_span.save!
    end
  end

end

