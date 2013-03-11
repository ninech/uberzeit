class DateEntry < Entry
  validates_presence_of :time_sheet, :time_type, :start_date, :end_date

  validates_datetime :start_date
  validates_datetime :end_date, on_or_after: :start_date

  scope :between, lambda { |between_range|
    between_date_range = between_range.to_date_range
    { conditions: ['(start_date <= ? AND end_date >= ?)', between_date_range.max, between_date_range.min] }
  }

  def self.to_chunks
    scoped.collect do |date_entry|
      # iterate through each day and add the semi days as chunks
      date_entry.range.collect { |day| TimeChunk.new(range: date_entry.time_range(day), time_type: date_entry.time_type, parent: date_entry) }
    end.flatten
  end

  def whole_day?
    # true when both or none of the flags is set
    not first_half_day? ^ second_half_day?
  end

  def first_half_day?
    !!first_half_day
  end

  def second_half_day?
    !!second_half_day
  end

  def starts
    start_date
  end

  def ends
    end_date
  end

  def time_range(day)
    time_start = day.midnight
    time_end = day.midnight + 1.day

    # calculates the time range for the given day
    time_end = time_end - 12.hours if first_half_day? && !whole_day?
    time_start = time_start + 12.hours if second_half_day? && !whole_day?

    (time_start..time_end)
  end

  def self.model_name
    # generate paths for parent class
    Entry.model_name
  end
end

