# == Schema Information
#
# Table name: absences
#
#  id              :integer          not null, primary key
#  time_sheet_id   :integer
#  time_type_id    :integer
#  start_date      :date
#  end_date        :date
#  first_half_day  :boolean          default(FALSE)
#  second_half_day :boolean          default(FALSE)
#  deleted_at      :datetime
#

class Absence < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type, with_deleted: true
  has_one :recurring_schedule, as: :enterable, dependent: :destroy

  default_scope order(:start_date)
  scope :work, joins: :time_type, conditions: ['is_work = ?', true]
  scope :absence, joins: :time_type, conditions: ['is_work = ?', false]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]

  attr_accessible :start_date, :end_date, :first_half_day, :second_half_day, :daypart
  attr_accessible :recurring_schedule, :recurring_schedule_attributes
  attr_accessible :time_sheet_id, :time_type_id, :type

  validates_presence_of :start_date, :end_date
  validates_presence_of :time_sheet, :time_type
  after_initialize :set_default_dates

  validates_datetime :start_date
  validates_datetime :end_date, on_or_after: :start_date

  accepts_nested_attributes_for :recurring_schedule

  before_validation :build_recurring_schedule, unless: :recurring_schedule



  def self.nonrecurring_entries_in_range(range)
    date_range = range.to_date_range
    nonrecurring_entries.where('(start_date <= ? AND end_date >= ?)', date_range.max, date_range.min)
  end

  def self.recurring_entries
    # inner join
    scoped.joins(:recurring_schedule).where(recurring_schedules: {active: true})
  end

  def self.nonrecurring_entries
    # left outer join
    scoped.includes(:recurring_schedule).where(recurring_schedules: {active: false})
  end

  def self.recurring_entries_in_range(range)
    recurring_entries.collect { |entry| entry if entry.recurring_schedule.occurring?(range) }.compact
  end

  def self.entries_in_range(range)
    recurring_entries_in_range(range) + nonrecurring_entries_in_range(range)
  end

  def duration
    range.duration
  end

  def range
    (starts..ends)
  end

  def recurring?
    recurring_schedule && recurring_schedule.active?
  end

  def occurrences(date_or_range)
    if recurring?
      recurring_schedule.occurrences(date_or_range)
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

end

