class CalculatePlannedWorkingTime
  # user can be nil to request the planned working time for a range
  def initialize(date_or_range, user = nil, opts = {})
    @user = user
    @range = date_or_range.to_range.to_date_range
    @opts = opts
  end

  def total
    planned_working_time
  end

  private

  def duration_in_days
    @range.max - @range.min + 1
  end

  def workload_on_date
    employment_on_date = @employments.find { |employment| employment.on_date?(@date) }
    return 0 if employment_on_date.nil?
    return 1 if !!@opts[:fulltime] # overwrite to fulltime workload
    employment_on_date.workload / 100.0
  end

  def preload_employments
    @employments = @user.employments.between(@range).to_a
  end

  def preload_public_holidays
    @public_holidays = PublicHoliday.in(@range).to_a
  end

  def planned_working_time
    preload_public_holidays
    preload_employments unless @user.nil?

    @range.inject(0.0) do |sum, date|
      @date = date
      workload_factor = if @user.nil?
                          1
                        else
                          workload_on_date
                        end
      sum + work_coefficient_on_date * workload_factor * UberZeit::Config[:work_per_day]
    end
  end

  def work_coefficient_on_date
    if is_work_day?
      if is_half_day_a_public_holiday?
        0.5
      else
        1
      end
    else
      0
    end
  end

  def is_work_day?
    UberZeit.is_weekday_a_workday?(@date) and not is_whole_day_a_public_holiday?
  end

  def is_half_day_a_public_holiday?
    @public_holidays.any? { |holiday| holiday.half_day? && holiday.on_date?(@date) }
  end

  def is_whole_day_a_public_holiday?
    @public_holidays.any? { |holiday| holiday.whole_day? && holiday.on_date?(@date) }
  end
end
