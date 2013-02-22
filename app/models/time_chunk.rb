# SingleTimes, RecurringTimes etc. are converted to TimeChunk for calculations and display
# E.g. a SingleTime entry with start 2013/01/01 8am to 2013/01/02 6pm will result in two seperate time entries
# which can be handled on a per-day basis
class TimeChunk
  attr_accessor :start_time, :end_time, :time_type, :parent

  def initialize(opts)
    if opts[:range]
      self.start_time = opts[:range].min
      self.end_time = opts[:range].max
    else
      self.start_time = opts[:start_time]
      self.end_time = opts[:end_time]
    end
    self.parent = opts[:parent]
    self.time_type = opts[:time_type]
  end

  def duration
    (start_time..end_time).duration
  end
end