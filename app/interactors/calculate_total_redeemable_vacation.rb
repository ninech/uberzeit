class CalculateTotalRedeemableVacation

  def initialize(user, year)
    @user = user
    @year = year
  end

  def total_redeemable_for_year(round_result_to_half_work_days = true)
    total_from_employments = employments_for_year.inject(0.0) { |sum, employment| sum + redeemable_vacation_for_employment(employment) }

    total = total_from_employments + total_adjustments_for_year

    if round_result_to_half_work_days
      round_to_half_work_days(total)
    else
      total
    end
  end

  private

  def total_adjustments_for_year
    adjustments_in_year.sum(&:duration)
  end

  def first_day_of_year
    @first_day_of_year ||= Date.new(@year,1,1)
  end

  def year_as_range
    @year_as_range ||= UberZeit.year_as_range(@year)
  end

  def employments_for_year
    @employments_for_year ||= @user.employments.between(year_as_range)
  end

  def default_vacation_per_year
    @default_vacation_per_year ||= UberZeit::Config[:vacation_per_year] / 1.day * UberZeit::Config[:work_per_day]
  end

  def redeemable_vacation_for_employment(employment)
    planned_working_time_for_employment_in_year(employment) / planned_working_time_in_year * default_vacation_per_year
  end

  def planned_working_time_in_year
    CalculatePlannedWorkingTime.new(year_as_range).total
  end

  def planned_working_time_for_employment_in_year(employment)
    CalculatePlannedWorkingTime.new(employment_range_in_year(employment), @user).total
  end

  def employment_range_in_year(employment)
    if employment.open_ended?
      employment_range_open_ended employment
    else
      employment_range_defined_end employment
    end
  end

  def employment_range_open_ended(employment)
    year_as_range.intersect((employment.start_date..(first_day_of_year + 1.year)))
  end

  def employment_range_defined_end(employment)
    year_as_range.intersect((employment.start_date..employment.end_date))
  end

  def in_half_work_days(duration)
    duration/half_work_day
  end

  def round_to_half_work_days(duration)
    in_half_work_days(duration).round * half_work_day
  end

  def half_work_day
    0.5*UberZeit::Config[:work_per_day]
  end

  def adjustments
    Adjustment.vacation.joins(:time_sheet).where(:time_sheets => { user_id: @user })
  end

  def adjustments_in_year
    adjustments.in(year_as_range)
  end
end

