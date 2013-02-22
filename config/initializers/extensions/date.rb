class Date
  def to_range
    (self.midnight..self.next_day.midnight)
  end
end