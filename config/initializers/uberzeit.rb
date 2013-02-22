# uberZeit specific time settings
module UberZeit 
  config = ActiveSupport::OrderedOptions.new

  config[:rounding] = 5.minutes
  config[:work_days] = [:monday, :tuesday, :wednesday, :thursday, :friday]
  config[:work_per_day] = 8.5.hours
  
  const_set('Config', config)
end

# move to a more appriopriate place in the future
UberZeit.module_eval do
  def self.is_work_day?(date)
    UberZeit::Config[:work_days].include?(date.strftime('%A').downcase.to_sym)
  end

  def self.total_default_work_duration_for(date_or_range)
    range = date_or_range.to_range

    if range.duration <= 24.hours
      total = is_work_day?(range.min) ? UberZeit::Config[:work_per_day] : 0
    else
      total = range.inject(0) do |sum, date|
        sum + (is_work_day?(date) ? UberZeit::Config[:work_per_day] : 0)
      end
    end

    total
  end
end


=begin
# general
config.uberzeit.vacation_per_year = 25.days

# overtime
config.uberzeit.overtime_limit_per_day = 2.hours
config.uberzeit.overtime_limit_per_year = 170.hours

# pikett
config.uberzeit.onduty_limit_per_block = 7.days
config.uberzeit.onduty_block_length = 4.weeks
config.uberzeit.onduty_block_break_length = 2.weeks
=end