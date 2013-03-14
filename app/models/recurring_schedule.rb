class RecurringSchedule < ActiveRecord::Base
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
  validates_inclusion_of :monthly_repeat_by, in: MONTHLY_REPEAT_BY_CONDITIONS, if: lambda {|schedule| schedule.repeat_interval_type == 'monthly'}

  validates_presence_of :enterable

  validates :daily_repeat_interval, numericality: {greater_than: 0}, if: lambda {|schedule| schedule.repeat_interval_type == 'daily'}
  validates :weekly_repeat_interval, numericality: {greater_than: 0}, if: lambda {|schedule| schedule.repeat_interval_type == 'weekly'}
  validates :monthly_repeat_interval, numericality: {greater_than: 0}, if: lambda {|schedule| schedule.repeat_interval_type == 'monthly'}
  validates :yearly_repeat_interval, numericality: {greater_than: 0}, if: lambda {|schedule| schedule.repeat_interval_type == 'yearly'}

  validates :ends_counter, numericality: {greater_than: 0}, if: lambda {|schedule| schedule.ends == 'counter'}
  validates_date :ends_date,  if: lambda {|schedule| schedule.ends == 'date'}

  serialize :weekly_repeat_weekday

  def active?
    !!active
  end

  def entry
    enterable
  end

  def occurrences(date_or_range)
    range_of_occurrences = date_or_range.to_range.to_time_range

    opening_time, closing_time = range_of_occurrences.min, range_of_occurrences.max

    schedule = self.to_ice_cube_schedule

    # We need to convert dates to times because of issue 153 (see below)
    opening_time = opening_time.midnight if opening_time.kind_of?(Date)
    closing_time = closing_time.midnight if closing_time.kind_of?(Date)

    # Issue 152: IceCube Bug https://github.com/seejohnrun/ice_cube/issues/152
    # Make sure the time zones are identical to the schedules' zone
    opening_time = opening_time.in_time_zone(schedule.start_time.zone) if opening_time.kind_of?(Time)
    closing_time = closing_time.in_time_zone(schedule.start_time.zone) if closing_time.kind_of?(Time)

    # Issue 153/154: Subtract the duration to make sure the requested time window is below the start time of the entry's start time if intersecting
    # cf. https://github.com/seejohnrun/ice_cube/issues/153 and https://github.com/seejohnrun/ice_cube/issues/154
    find_from = opening_time-schedule.duration
    find_to = closing_time
    start_times_of_occurrences = []

    schedule.occurrences_between(find_from, find_to).each do |occurrence|
      # make sure we use rails' time zone
      starts = occurrence.start_time.in_time_zone(Time.zone)
      occurrence_range = starts..starts+schedule.duration

      # make sure the occurrence overlaps with the range (due to the 153/154 workaround above)
      intersect = occurrence_range.intersect(range_of_occurrences)
      if intersect && intersect.duration > 0
        start_times_of_occurrences << starts
      end
    end

    start_times_of_occurrences
  end

  def occurring?(date_or_range)
    occurrences(date_or_range).any?
  end

  def to_ice_cube_schedule
    time_range = entry.range.to_time_range
    schedule = IceCube::Schedule.new(time_range.min, end_time: time_range.max)

    rule =  case repeat_interval_type
            when 'daily'
              IceCube::Rule.daily(daily_repeat_interval)
            when 'weekly'
              rule = IceCube::Rule.weekly(weekly_repeat_interval)
              unless weekly_repeat_weekday.blank?
                rule.day(*weekly_repeat_weekday.map(&:to_i))
              end
              rule
            when 'monthly'
              rule = IceCube::Rule.monthly(monthly_repeat_interval)
              start_date = entry.starts.to_date
              if monthly_repeat_by == 'day_of_week'
                rule.day_of_week(start_date.wday => [RecurringSchedule.number_of_weekday_occurrence_in_month(start_date)]) # the Xth weekday in the month
              else
                rule.day_of_month(start_date.day) # on the day X of month
              end
              rule
            when 'yearly'
              IceCube::Rule.yearly(yearly_repeat_interval)
            else
              raise "No valid repeat unit"
            end

    case ends
    when 'counter'
      rule.count(ends_counter)
    when 'date'
      rule.until(ends_date.midnight) # make sure we convert the date to the rails' time zone using midnight
    end

    schedule.add_recurrence_rule(rule)

    schedule
  end

  # e.g. 2013-07-14: 2th thursday, return 2
  def self.number_of_weekday_occurrence_in_month(date)
    current_date = date.beginning_of_month
    number = 1
    while current_date < date
      number += 1 if current_date.wday == date.wday
      current_date += 1
    end
    number
  end
end
