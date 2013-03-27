# SingleTimes, RecurringTimes etc. are converted to TimeChunks for calculations and display
class TimeChunk
  attr_accessor :starts, :ends, :time_type, :parent
  attr_writer :duration

  def initialize(opts)
    if opts[:range]
      @starts = opts[:range].min
      @ends = opts[:range].max
    else
      @starts = opts[:starts]
      @ends = opts[:ends]
    end
    @parent = opts[:parent]
    @time_type = opts[:time_type]
    @duration = opts[:duration]
  end

  def range
    (starts..ends)
  end

  def duration
    @duration ||= range.duration
  end

  def half_day_specific?
    parent.respond_to?(:whole_day?)
  end

  def method_missing(sym, *args, &block)
    @parent.send(sym, *args, &block)
  end

  def parent_id
    @parent_id ||= parent.id
  end
end
