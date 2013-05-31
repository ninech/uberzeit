# Monkey patch range
# Code from http://www.postal-code.com/binarycode/2009/06/06/better-range-intersection-in-ruby/
class Range
  def intersect(other)
    raise ArgumentError, 'value must be a Range' unless other.kind_of?(Range)

    this = self

    # make sure we convert first when comparing a TimeRange to a DateRange
    # midnight respects Time.zone, to_time won't
    this = this.to_time_range if this.min.kind_of?(Date) && other.min.kind_of?(Time)
    other = other.to_time_range if this.min.kind_of?(Time) && other.min.kind_of?(Date)

    # Although this intersection is valid, we don't expect this behaviour in UZ
    # You should always intersect the SAME TIME ZONES to prevent calculation errors
    if this.kind_of?(Time) && other.kind_of?(Time)
      if this.min.zone != other.min.zone
        raise "Trying to intersect two different time zones"
      end
    end

    my_min, my_max = this.first, this.exclude_end? ? this.max : this.last
    other_min, other_max = other.first, other.exclude_end? ? other.max : other.last

    new_min = this.cover?(other_min) ? other_min : other.cover?(my_min) ? my_min : nil
    new_max = this.cover?(other_max) ? other_max : other.cover?(my_max) ? my_max : nil

    new_min && new_max ? new_min..new_max : nil
  end

  def duration
    range = self.to_time_range
    (range.max - range.min).to_i
  end

  def intersects_with_duration?(other)
    intersection = intersect(other)
    not intersection.nil? and intersection.duration > 0
  end

  def to_range
    self
  end

  def to_date_range
    case min
    when Date
      self.dup
    when String
      (Date.parse(min)..Date.parse(max))
    when Time
      # (2013-07-20 00:00:00..2013-07-22 00:00:00) should result in (2013-07-20..2013-07-21)
      # whereas
      # (2013-07-20 00:00:00..2013-07-22 12:00:00) should result in (2013-07-20..2013-07-22)
      (min.to_date..(max - max.midnight > 0 ? max.to_date : max.to_date - 1.day))
    else
      (min.to_date..max.to_date)
    end
  end

  def to_time_range
    case min
    when Date
      # Midnight is Time.zone aware
      (min.midnight..max.next_day.midnight)
    when String
      (Time.zone.parse(min)..Time.zone.parse(max))
    when Time
      self.dup
    else
      (min.to_time..max.to_time)
    end
  end

  alias_method :&, :intersect
end
