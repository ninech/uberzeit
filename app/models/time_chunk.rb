# SingleTimes, RecurringTimes etc. are converted to TimeChunk for calculations and display
# E.g. a SingleTime entry with start 2013/01/01 8am to 2013/01/02 6pm will result in two seperate time entries
# which can be handled on a per-day basis
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

  def duration
    (starts..ends).duration
  end
end