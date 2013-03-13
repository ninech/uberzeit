class RecurringSchedule < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible   :active, :ends, :ends_counter, :ends_date, :enterable, :repeat_interval_type,
                    :daily_repeat_interval,
                    :monthly_repeat_by, :monthly_repeat_interval,
                    :weekly_repeat_interval, :weekly_repeat_weekday,
                    :yearly_repeat_interval

  validates :repeat_interval_type, inclusion: { in: %w(daily weekly monthly yearly) }
  validates :ends, inclusion: { in: %w(never counter date) }

  serialize :weekly_repeat_weekday

  belongs_to :enterable, polymorphic: true

  def active?
    !!active
  end

  def entry
    enterable
  end

  def occurrences(date_or_range)
    range = date_or_range.to_range.to_time_range

    opening_time, closing_time = range.min, range.max

    schedule = ice_cube_schedule

    # We need to convert dates to times because of issue 153 (see below)
    opening_time = opening_time.midnight if opening_time.kind_of?(Date)
    closing_time = closing_time.midnight if closing_time.kind_of?(Date)

    # Issue 152: IceCube Bug https://github.com/seejohnrun/ice_cube/issues/152
    # Make sure the time zones are identical to the schedules' zone
    opening_time = opening_time.in_time_zone(schedule.start_time.zone) if opening_time.kind_of?(Time)
    closing_time = closing_time.in_time_zone(schedule.start_time.zone) if closing_time.kind_of?(Time)

    # Issue 153/154: Subtract the duration to make sure the requested time window is below the start time of the entry's start time if intersecting
    # cf. https://github.com/seejohnrun/ice_cube/issues/153 and https://github.com/seejohnrun/ice_cube/issues/154
    occurrences_from = opening_time - schedule.duration
    occurrences_to = closing_time

    occurrences_start_time = []

    schedule.occurrences_between(occurrences_from, occurrences_to).each do |occurrence|
      # make sure we use rails' time zone
      starts = occurrence.start_time.in_time_zone(Time.zone)
      occurrences_start_time << starts
    end

    occurrences_start_time
  end

  def occurring?(date_or_range)
    occurrences(date_or_range).any?
  end

  def ice_cube_schedule
    schedule = IceCube::Schedule.new(entry.starts, end_time: entry.ends)

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
              if monthly_repeat_by == 'weekday'
                rule.day_of_week(start_time.to_date.wday => [1]) # on the first weekday X of month
              else
                rule.day_of_month(start_time.to_date.day) # on the day X of month
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
      rule.until(ends_date)
    end

    schedule.add_recurrence_rule rule

    schedule
  end
end
