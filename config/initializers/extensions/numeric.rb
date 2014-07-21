class Numeric
  def to_hours
    to_f / 1.hour
  end

  def to_days
    to_f / 24.hours
  end

  def work_days
    to_f * Setting.work_per_day_hours.hours
  end

  def to_work_days
    to_f / Setting.work_per_day_hours.hours
  end

  def to_minutes
    to_f / 1.minute
  end

end
