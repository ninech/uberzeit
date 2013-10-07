module UberZeit
  # create initial Configuration
  Config = ActiveSupport::OrderedOptions.new

  def self.is_work_day?(date)
    is_weekday_a_workday?(date) and not PublicHoliday.whole_day_on?(date)
  end

  def self.is_weekday_a_workday?(date)
   UberZeit::Config[:work_days].include?(date.strftime('%A').downcase.to_sym)
  end

  def self.year_as_range(year)
    Date.new(year)...Date.new(year+1)
  end

  def self.month_as_range(year, month)
    first_day_of_month = Date.new(year, month)
    last_day_of_month = first_day_of_month.end_of_month
    first_day_of_month..last_day_of_month
  end

  def self.round(duration, smallest_unit = UberZeit::Config[:rounding])
    (duration.to_f / smallest_unit.to_f).round * smallest_unit
  end

  def self.duration_in_hhmm(duration)
    hours = duration.to_hours.to_i
    minutes = (duration - hours * 1.hour).to_minutes.round
    is_negative = hours < 0 || minutes < 0

    if is_negative
      "-%02i:%02i" % [hours.abs, minutes.abs]
    else
      "%02i:%02i" % [hours, minutes]
    end
  end

  def self.hhmm_in_duration(hhmm)
    hours, minutes = hhmm.split(':').map(&:to_f)
    if hhmm.index('-')
      -1 * (hours.hours.abs + minutes.minutes.abs)
    else
      hours.hours + minutes.minutes
    end
  end

  def self.range_to_buckets(range, interval, start_from)
    cursor = start_from
    buckets = []
    while cursor <= range.max
      range_at_cursor = cursor...cursor + interval
      buckets.push range_at_cursor.intersect(range)
      cursor += interval
    end
    buckets
  end
end
