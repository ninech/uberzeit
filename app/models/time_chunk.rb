# SingleTimes, RecurringTimes etc. are converted to TimeChunks for calculations and display
class TimeChunk
  attr_accessor :starts, :ends, :parent
  attr_writer :duration, :time_type

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
  end

  def range
    (starts..ends)
  end

  def duration
    range.duration
  end

  def time_bonus
    calculator = UberZeit::TimeTypeCalculators.use(time_type.bonus_calculator, self)
    calculator.result
  end

  def time_type
    @time_type ||= parent.time_type
  end

  def half_day_specific?
    parent.respond_to?(:whole_day?)
  end

  # def effective_duration
  #   duration * time_type.calculation_factor
  # end

  def method_missing(sym, *args, &block)
    @parent.send(sym, *args, &block)
  end

  def exclude_from_calculation?
    time_type.exclude_from_calculation?
  end

  def parent_id
    @parent_id ||= parent.id
  end
end
