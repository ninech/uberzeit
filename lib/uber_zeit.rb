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
end
