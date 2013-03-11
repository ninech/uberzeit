class DateEntry < Entry
  validates_presence_of :time_sheet, :time_type, :start_date, :end_date

  validates_datetime :start_date
  validates_datetime :end_date, on_or_after: :start_date

  scope :between, lambda { |between_range|
    between_date_range = between_range.to_date_range
    { conditions: ['(start_date <= ? AND end_date >= ?)', between_date_range.max, between_date_range.min] }
  }

  def whole_day?
    true
  end

  def starts
    start_date.midnight
  end

  def ends
    end_date.midnight + 1.day # end date is inclusive
  end

  def self.model_name
    # generate paths for parent class
    Entry.model_name
  end
end

