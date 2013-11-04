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
#  created_at      :datetime
#  updated_at      :datetime
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
  validate :must_not_overlap_with_other_absences

  accepts_nested_attributes_for :schedule, update_only: true

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

  def occurrences
    if recurring?
      schedule.occurrences
    else
      [range]
    end
  end

  def occurrences_as_time_ranges(date_or_range)
    requested_date_range = date_or_range.to_range.to_date_range
    # for date entries we have to generate a occurrence range for each day (half days are not continuous)
    occurrences.collect do |occurrence_range|
      next unless occurrence_range.intersects_with_duration?(requested_date_range)
      occurrence_range.collect { |day| time_range_for_date(day) }
    end.compact.flatten
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

  def update_or_create_time_span
    time_spans.destroy_all
    schedule.reload
    occurrences.each do |occurrence|
      occurrence.each do |date|
        create_time_span_for_date(date)
      end
    end
  end

  def create_time_span_for_date(date)
    calculated_planned_working_time = CalculatePlannedWorkingTime.new(date.to_range, user, fulltime: true).total
    duration_in_work_days = (whole_day? ? 1 : 0.5) * calculated_planned_working_time.to_work_days

    credited_duration_in_work_days = if time_type.exclude_from_calculation?
                                       0
                                     else
                                       duration_in_work_days
                                     end

    time_span = time_spans.build
    time_span.duration_in_work_days = duration_in_work_days
    time_span.credited_duration_in_work_days = credited_duration_in_work_days
    time_span.user = user
    time_span.time_type = time_type
    time_span.date = date
    time_span.save!
  end

  # VIEWERS DISCRETION ADVISED
  #
  # The following code is a neat hack: Rails set
  # `schedule.absence` AFTER the creation of the Absence. For
  # unpersisted absences, schedule.absence is therefore `nil`.
  # Since the validation` must_not_overlap_with_other_absences`
  # uses `occurrences` which depends on `schedule.absence` being
  # set, we do this manually when building the absence. The code
  # is covered by our specs and believed to have no unpleasant
  # side effects.
  def build_schedule(*args)
    super(*args).tap do |schedule|
      schedule.absence = self
    end
  end

  private
  def must_not_overlap_with_other_absences
    conflicting_dates = find_conflicting_dates
    if conflicting_dates.any?
      errors.add(:start_date, :absences_overlap, dates: conflicting_dates.to_sentence)
    end
  end

  def find_conflicting_dates
    overlapping_time_spans = user.time_spans.absences.where(date: occurrences)
    overlapping_time_spans.collect do |time_span|
      absence = time_span.time_spanable
      next if absence == self
      next if absence.first_half_day != first_half_day && absence.second_half_day != second_half_day
      time_span.date
    end.compact.uniq
  end
end

