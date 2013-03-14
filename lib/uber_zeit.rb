module UberZeit
  # create initial Configuration
  Config = ActiveSupport::OrderedOptions.new

  def self.is_work_day?(date)
    UberZeit::Config[:work_days].include?(date.strftime('%A').downcase.to_sym)
  end

  def self.year_as_range(year)
    Date.new(year)...Date.new(year+1)
  end
end
