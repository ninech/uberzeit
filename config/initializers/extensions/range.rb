# Monkey patch range
# Code from http://www.postal-code.com/binarycode/2009/06/06/better-range-intersection-in-ruby/
class Range  
  def intersect(other)  
    raise ArgumentError, 'value must be a Range' unless other.kind_of?(Range)  
    
    this = self

    # make sure we convert first when comparing a TimeRange to a DateRange
    # midnight respects Time.zone, to_time won't
    this = (this.min.midnight..this.max.midnight) if this.min.kind_of?(Date) && other.min.kind_of?(Time)
    other = (other.min.midnight..other.max.midnight) if this.min.kind_of?(Time) && other.min.kind_of?(Date)

    # Although this intersection is valid, we don't expect this behaviour in UZ
    # You should always intersect the SAME TIME ZONES to prevent calculation errors
    if this.kind_of?(Time) && other.kind_of?(Time)
      raise "Trying to intersect two different time zones" if this.min.zone != other.min.zone
    end

    my_min, my_max = this.first, this.exclude_end? ? this.max : this.last  
    other_min, other_max = other.first, other.exclude_end? ? other.max : other.last  
      
    new_min = this.cover?(other_min) ? other_min : other.cover?(my_min) ? my_min : nil  
    new_max = this.cover?(other_max) ? other_max : other.cover?(my_max) ? my_max : nil  
  
    new_min && new_max ? new_min..new_max : nil  
  end  
  
  def duration
    return nil unless max.respond_to?(:strftime)
    # convert to time if date is supplied
    rs = min.kind_of?(Time) ? min : Time.parse(min.to_s)
    re = max.kind_of?(Time) ? max : Time.parse(max.to_s)
    (re - rs).to_i
  end

  def to_range
    self
  end

  alias_method :&, :intersect  
end  