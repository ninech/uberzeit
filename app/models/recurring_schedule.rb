class RecurringSchedule < ActiveRecord::Base
  include RecurringScheduleExtensions::IceCubeExtension

  acts_as_paranoid

  belongs_to :enterable, polymorphic: true

  attr_accessible   :active, :ends, :ends_counter, :ends_date, :enterable, :repeat_interval_type,
                    :daily_repeat_interval,
                    :weekly_repeat_interval, :weekly_repeat_weekday,
                    :monthly_repeat_by, :monthly_repeat_interval,
                    :yearly_repeat_interval

  REPEAT_INTERVAL_TYPES = %w(daily weekly monthly yearly)
  ENDING_CONDITIONS = %w(never counter date)
  MONTHLY_REPEAT_BY_CONDITIONS = %w(day_of_week day_of_month)

  validates_inclusion_of :repeat_interval_type, in: REPEAT_INTERVAL_TYPES
  validates_inclusion_of :ends, in: ENDING_CONDITIONS
  validates_inclusion_of :monthly_repeat_by, in: MONTHLY_REPEAT_BY_CONDITIONS, if: :repeat_monthly?

  validates_presence_of :enterable

  validates_numericality_of :daily_repeat_interval, greater_than: 0, if: :repeat_daily?
  validates_numericality_of :weekly_repeat_interval, greater_than: 0, if: :repeat_weekly?
  validates_numericality_of :monthly_repeat_interval, greater_than: 0, if: :repeat_monthly?
  validates_numericality_of :yearly_repeat_interval, greater_than: 0, if: :repeat_yearly?

  validates_numericality_of :ends_counter, greater_than: 0, if: :ends_on_counter?

  validates_date :ends_date, if: :ends_on_date?

  serialize :weekly_repeat_weekday

  def active?
    !!active
  end

  def entry
    enterable
  end

  def repeat_daily?
    repeat_interval_type == 'daily'
  end

  def repeat_weekly?
    repeat_interval_type == 'weekly'
  end

  def repeat_monthly?
    repeat_interval_type == 'monthly'
  end

  def repeat_yearly?
    repeat_interval_type == 'yearly'
  end

  def ends_on_date?
    ends == 'date'
  end

  def ends_on_counter?
    ends == 'counter'
  end

  # e.g. 2013-07-14: 2th thursday, return 2
  def self.number_of_weekday_occurrence_in_month(date)
    current_date = date.beginning_of_month
    occurrence_number = 1
    while current_date < date
      occurrence_number += 1 if current_date.wday == date.wday
      current_date += 1
    end
    occurrence_number
  end
end
