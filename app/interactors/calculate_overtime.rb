class CalculateOvertime

  def initialize(time_sheet, date_or_range)
    @time_sheet = time_sheet
    @user = @time_sheet.user
    @date_or_range = date_or_range
  end

  def total
    # planned work is immutable
    # entries count towards the planned work time for the specified date range
    total_worktime + total_bonuses + total_absences + total_adjustments - planned_work
  end

  private

  def planned_work
    @planned_work ||= @time_sheet.planned_work(@date_or_range)
  end

  def total_worktime
    @total_worktime ||= @time_sheet.total(@date_or_range, TimeType.work)
  end

  def total_bonuses
    @total_bonuses ||= @time_sheet.bonus(@date_or_range, TimeType.work)
  end

  def total_absences
    @total_absences ||= @time_sheet.total(@date_or_range, TimeType.absence)
  end

  def total_adjustments
    @total_adjustments ||= @user.adjustments.exclude_vacation.in(@date_or_range).total_duration
  end
end

