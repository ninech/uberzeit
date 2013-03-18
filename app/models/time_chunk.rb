# SingleTimes, RecurringTimes etc. are converted to TimeChunks for calculations and display
class TimeChunk
  attr_accessor :starts, :ends, :time_type, :parent

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
  end

  def range
    (starts..ends)
  end

  def duration
    if time_type.calculate_work_hours_only?
      range.duration.to_f / 24.hours * UberZeit::Config[:work_per_day]
    else
      range.duration
    end
  end

  def first_half_day?
    @first_half_day ||= half_day_specific? && parent.first_half_day?
  end

  def second_half_day?
    @second_half_day ||= half_day_specific? && parent.second_half_day?
  end

  def whole_day?
    @whole_day ||= half_day_specific? && parent.whole_day?
  end

  def half_day_specific?
    @half_day_specific ||= parent.respond_to?(:whole_day?)
  end
end
