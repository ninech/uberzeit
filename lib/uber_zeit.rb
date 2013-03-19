module UberZeit
  # create initial Configuration
  Config = ActiveSupport::OrderedOptions.new

  def self.is_work_day?(date)
    UberZeit::Config[:work_days].include?(date.strftime('%A').downcase.to_sym) and not PublicHoliday.whole_day_on?(date)
  end

  def self.default_work_hours_on(date)
    default_work_hours_coefficient(date) * UberZeit::Config[:work_per_day]
  end

  def self.year_as_range(year)
    Date.new(year)...Date.new(year+1)
  end

  private

  def self.default_work_hours_coefficient(date)
    return 0 unless is_work_day?(date)
    return 0.5 if PublicHoliday.half_day_on?(date)
    1
  end
end
