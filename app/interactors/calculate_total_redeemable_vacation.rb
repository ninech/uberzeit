class CalculateTotalRedeemableVacation

  def initialize(user, year)
    @user = user
    @year = year
    @total = 0.0
  end

  def total_redeemable_for_year
    total = employments_for_year.inject(0.0) do |sum, employment|
      sum + redeemable_vacation_for_employment(employment)
    end

    round_to_half_work_days(total)
  end

  private
  def first_day_of_year
    @first_day_of_year ||= Time.zone.now.beginning_of_year.to_date
  end

  def year_as_range
    @year_as_range ||= first_day_of_year...(first_day_of_year + 1.year)
  end

  def employments_for_year
    @employments_for_year ||= @user.employments.between(year_as_range)
  end

  def default_vacation_per_year
    @default_vacation_per_year ||= UberZeit::Config[:vacation_per_year] / 1.day * UberZeit::Config[:work_per_day]
  end

  def employment_duration(employment)
    if employment.open_ended?
      employment_duration_open_ended employment
    else
      employment_duration_defined_end employment
    end
  end

  def employment_duration_open_ended(employment)
    year_as_range.intersect((employment.start_date..(first_day_of_year + 1.year))).duration
  end

  def employment_duration_defined_end(employment)
    year_as_range.intersect((employment.start_date..employment.end_date)).duration
  end

  def redeemable_vacation_for_employment(employment)
    employment.workload * 0.01 * employment_duration(employment) / year_as_range.duration * default_vacation_per_year
  end

  def round_to_half_work_days(seconds)
    half_day = UberZeit::Config[:work_per_day]*0.5
    (seconds/half_day).round * half_day
  end

end

