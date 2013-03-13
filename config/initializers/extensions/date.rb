class Date
  def to_range
    (self..self)
  end

  # http://www.betaful.com/2012/09/date-time-and-activesupporttimewithzone/
  def to_time
    Time.zone.local(self.year, self.month, self.day, 0, 0, 0)
  end

  def current
    Time.current.to_date
  end
end
