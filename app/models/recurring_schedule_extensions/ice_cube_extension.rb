module RecurringScheduleExtensions
  module IceCubeExtension
    extend ActiveSupport::Concern

    def occurrences(date_or_range)
      range_of_occurrences = date_or_range.to_range.to_time_range

      opening_time, closing_time = range_of_occurrences.min, range_of_occurrences.max

      schedule = create_schedule

      # 1) Issue 153: We need to convert dates to times because of issue 153 (see below)
      # 2) Issue 152: Make sure the time zones are identical to the schedules' zone (IceCube Bug https://github.com/seejohnrun/ice_cube/issues/152)
      opening_time = convert_to_time(opening_time, schedule.start_time.zone)
      closing_time = convert_to_time(closing_time, schedule.start_time.zone)

      # Issue 153/154: Subtract the duration to make sure the requested time window is below the start time of the entry's start time if intersecting
      # cf. https://github.com/seejohnrun/ice_cube/issues/153 and https://github.com/seejohnrun/ice_cube/issues/154
      find_from = opening_time - schedule.duration
      find_to = closing_time
      start_times_of_occurrences = []

      schedule.occurrences_between(find_from, find_to).each do |occurrence|
        # make sure we use rails' time zone
        occurrence_start = occurrence.start_time.in_time_zone(Time.zone)
        occurrence_range = occurrence_start..occurrence_start+schedule.duration

        # make sure the occurrence overlaps with the range (due to the 153/154 workaround above)
        intersect = occurrence_range.intersect(range_of_occurrences)
        if intersect && intersect.duration > 0
          start_times_of_occurrences << occurrence_start
        end
      end

      start_times_of_occurrences
    end

    def occurring?(date_or_range)
      occurrences(date_or_range).any?
    end

    def create_schedule
      time_range = entry.range.to_time_range
      schedule = IceCube::Schedule.new(time_range.min, end_time: time_range.max)
      schedule.add_recurrence_rule create_rule
      schedule
    end

    def create_rule
      rule = self.send("create_#{repeat_interval_type}_rule")
      add_ending_condition(rule)
      rule
    end

    def create_daily_rule
      IceCube::Rule.daily(daily_repeat_interval)
    end

    def create_weekly_rule
      rule = IceCube::Rule.weekly(weekly_repeat_interval)
      unless weekly_repeat_weekday.blank?
        rule.day(*weekly_repeat_weekday.map(&:to_i))
      end
      rule
    end

    def create_monthly_rule
      rule = IceCube::Rule.monthly(monthly_repeat_interval)
      start_date = entry.starts.to_date
      if monthly_repeat_by == 'day_of_week'
        rule.day_of_week(start_date.wday => [RecurringSchedule.number_of_weekday_occurrence_in_month(start_date)]) # the Xth weekday in the month
      else
        rule.day_of_month(start_date.day) # on the day X of month
      end
      rule
    end

    def create_yearly_rule
      IceCube::Rule.yearly(yearly_repeat_interval)
    end

    def add_ending_condition(rule)
      case ends
      when 'counter'
        rule.count(ends_counter)
      when 'date'
        rule.until(ends_date.midnight) # make sure we convert the date to the rails' time zone using midnight
      end
    end

    private

    def convert_to_time(date_or_time, zone)
      time = date_or_time.kind_of?(Date) ? date_or_time.midnight : date_or_time
      time.in_time_zone(zone)
    end
  end
end
