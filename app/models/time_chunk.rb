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
    range.duration
  end
end
