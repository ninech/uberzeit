class Date
  def to_range
    # Midnight is Time.zone aware
    (self.midnight..self.next_day.midnight)
  end
end