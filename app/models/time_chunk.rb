# SingleTimes, RecurringTimes etc. are converted to TimeChunks for calculations and display
class TimeChunk
  attr_accessor :starts, :ends, :time_type, :parent

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

  def duration_for_calculation
    duration * @time_type.calculation_factor
  end

  def parent_id
    @parent_id ||= parent.id
  end
end
