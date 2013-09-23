class CalculateRedeemedVacation

  def initialize(user, range)
    @user = user
    @range = range
    @total = 0.0
  end

  def total(round_result_to_half_work_days = true)
    total = redeemed_vacation_for_time_sheet @user.time_sheet

    if round_result_to_half_work_days
      round_to_half_work_days(total)
    else
      total
    end
  end

  private

  def in_half_work_days(duration)
    duration/half_work_day
  end

  def redeemed_vacation_for_time_sheet(time_sheet)
    time_sheet.total(@range, TimeType.vacation)
  end

  def round_to_half_work_days(duration)
    in_half_work_days(duration).round * half_work_day
  end

  def half_work_day
    0.5*UberZeit::Config[:work_per_day]
  end
end

