class Vacation

  def initialize(user, year)
    @user = user
    @year = year
    @total = 0.0
  end

  def total_redeemable_for_year
    total = employments_for_year.inject(0.0) do |sum, employment|
      employment_duration = if employment.open_ended?
                              year_as_range.intersect((employment.start_date..(first_day_of_year + 1.year))).duration
                            else
                              year_as_range.intersect((employment.start_date..employment.end_date)).duration
                            end
      sum + employment.workload * 0.01 * employment_duration/year_as_range.duration * default_vacation_per_year
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
    @employments_for_year ||= @user.employments.between(year_as_range.min, year_as_range.max)
  end

  def default_vacation_per_year
    @default_vacation_per_year ||= UberZeit::Config[:vacation_per_year] / 1.day * UberZeit::Config[:work_per_day]
  end

  def round_to_half_work_days(seconds)
    half_day = UberZeit::Config[:work_per_day]*0.5
    (seconds/half_day).round * half_day
  end

end

