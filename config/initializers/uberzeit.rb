# uberZeit specific time settings

config = Rails.application.config
config.uberzeit = ActiveSupport::OrderedOptions.new

=begin
# general
config.uberzeit.working_hours_per_day = 8.5
config.uberzeit.working_days_per_week = 5
config.uberzeit.vacation_days_per_year = 25

# overtime
config.uberzeit.overtime_limit_hours_per_day = 2
config.uberzeit.overtime_limit_hours_per_year = 170

# pikett
config.uberzeit.onduty_limit_days_per_block = 7
config.uberzeit.onduty_block_length_weeks = 4
config.uberzeit.onduty_block_break_length_weeks = 2
=end