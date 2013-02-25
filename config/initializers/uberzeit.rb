# uberZeit specific time settings
module UberZeit 
  Config = ActiveSupport::OrderedOptions.new

  Config[:rounding] = 5.minutes
  Config[:work_days] = [:monday, :tuesday, :wednesday, :thursday, :friday]
  Config[:work_per_day] = 8.5.hours
  Config[:vacation_per_year] = 25.days
end

# move to a more appriopriate place in the future
UberZeit.module_eval do
  def self.is_work_day?(date)
    UberZeit::Config[:work_days].include?(date.strftime('%A').downcase.to_sym)
  end

  def self.total_planned_work_duration(user, date_or_range, ignore_workload=false)
    range = date_or_range.to_range

    if range.duration <= 24.hours
      active_employment = user.employments.when(range.min).first
      workload = ignore_workload ? 1 : active_employment.workload * 0.01
      total = workload * (is_work_day?(range.min) ? UberZeit::Config[:work_per_day] : 0)
    else
      total = range.inject(0.0) do |sum, date|
        active_employment = user.employments.when(date).first
        workload = ignore_workload ? 1 : active_employment.workload * 0.01
        sum + workload * (is_work_day?(date) ? UberZeit::Config[:work_per_day] : 0)
      end
    end

    total
  end

  def self.total_available_vacation_duration(user, year)
    range = (Time.utc(year)..Time.utc(year+1))
    employments = user.employments.between(range.min, range.max)

    default_vacation_per_year = UberZeit::Config[:vacation_per_year]/1.day*UberZeit::Config[:work_per_day]

    total = employments.inject(0.0) do |sum, employment|
      # contribution to this year
      if employment.end_time.nil?
        contrib_year = range.intersect((employment.start_time..Time.utc(year+1))).duration
      else
        contrib_year = range.intersect((employment.start_time..employment.end_time)).duration
      end

      sum + employment.workload * 0.01 * contrib_year/range.duration * default_vacation_per_year
    end

    # round to half work days
    half_day = UberZeit::Config[:work_per_day]*0.5
    (total/half_day).round * half_day
  end
end


=begin
# general

# overtime
config.uberzeit.overtime_limit_per_day = 2.hours
config.uberzeit.overtime_limit_per_year = 170.hours

# pikett
config.uberzeit.onduty_limit_per_block = 7.days
config.uberzeit.onduty_block_length = 4.weeks
config.uberzeit.onduty_block_break_length = 2.weeks
=end