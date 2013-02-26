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

  def self.planned_work(user, date_or_range, ignore_workload=false)
    range = date_or_range.to_range

    if range.duration <= 1.day
      workload = ignore_workload ? 1 : workload_at(user, range.min) * 0.01
      total = workload * (is_work_day?(range.min) ? UberZeit::Config[:work_per_day] : 0)
    else
      raise "Expects a date range" unless date_or_range.min.kind_of?(Date)
      days = range.to_a
      days.pop # exclude the exclusive day
      total = days.inject(0.0) do |sum, date|
        workload = ignore_workload ? 1 : workload_at(user, date) * 0.01
        sum + workload * (is_work_day?(date) ? UberZeit::Config[:work_per_day] : 0)
      end
    end

    total
  end

  def self.workload_at(user, date)
    active_employment = user.employments.when(date).first
    return 0 unless active_employment
    return active_employment.workload
  end

  def self.total_vacation(user, year)
    current_year = Time.zone.now.beginning_of_year
    range = (current_year..current_year + 1.year)
    employments = user.employments.between(range.min, range.max)

    default_vacation_per_year = UberZeit::Config[:vacation_per_year]/1.day*UberZeit::Config[:work_per_day]

    total = employments.inject(0.0) do |sum, employment|
      # contribution to this year
      if employment.end_time.nil?
        contrib_year = range.intersect((employment.start_time..current_year + 1.year)).duration
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