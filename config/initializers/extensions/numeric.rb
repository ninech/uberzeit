class Numeric
  def to_hours
    self.to_f / 1.hour
  end

  def to_days
    self.to_f / 24.hours
  end

  def work_days
    self.to_f * UberZeit::Config[:work_per_day]
  end

  def to_work_days
    self.to_f / UberZeit::Config[:work_per_day]
  end

  def to_minutes
    self.to_f / 1.minute
  end

end