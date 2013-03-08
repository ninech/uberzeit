# SingleTimes, RecurringTimes etc. are converted to TimeChunks for calculations and display
class TimeChunk
  attr_accessor :starts, :ends, :time_type, :parent, :first_half_day, :second_half_day

  def initialize(opts)
    if opts[:range]
      self.starts = opts[:range].min
      self.ends = opts[:range].max
    else
      self.starts = opts[:starts]
      self.ends = opts[:ends]
    end
    self.parent = opts[:parent]
    self.time_type = opts[:time_type]
    self.first_half_day = opts[:first_half_day]
    self.second_half_day = opts[:second_half_day]
  end

  def range
    (starts..ends)
  end

  def duration
    if time_type.calculate_work_hours_only?
      UberZeit::Config[:work_per_day]
    else
      range.duration
    end
  end

  def whole_day?
    first_half_day && second_half_day
  end
end
