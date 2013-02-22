# uberZeit specific time settings

module UberZeit
  Config = ActiveSupport::OrderedOptions.new
end


UberZeit::Config[:rounding] = 5.minutes
=begin
# general
config.uberzeit.work_per_day = 8.5.hours
config.uberzeit.work_days = [:monday, :tuesday, :wednesday, :thursday, :friday]
config.uberzeit.vacation_per_year = 25.days

# overtime
config.uberzeit.overtime_limit_per_day = 2.hours
config.uberzeit.overtime_limit_per_year = 170.hours

# pikett
config.uberzeit.onduty_limit_per_block = 7.days
config.uberzeit.onduty_block_length = 4.weeks
config.uberzeit.onduty_block_break_length = 2.weeks
=end