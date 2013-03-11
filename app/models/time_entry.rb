class TimeEntry < Entry
  validates_presence_of :time_sheet, :time_type, :start_time, :end_time

  validates_datetime :start_time
  validates_datetime :end_time, after: :start_time

  before_validation :round_times

  # http://stackoverflow.com/questions/143552/comparing-date-ranges
  scope :between, lambda { |between_range|
    between_time_range = between_range.to_time_range
    { conditions: ['(start_time < ? AND end_time > ?)', between_time_range.max, between_time_range.min] }
  }

  def starts
    start_time
  end

  def ends
    end_time
  end

  def self.model_name
    # generate paths for parent class
    Entry.model_name
  end

  private

  def round_times
    self.start_time = start_time.round unless start_time.nil?
    self.end_time = end_time.round unless end_time.nil?
  end
end
