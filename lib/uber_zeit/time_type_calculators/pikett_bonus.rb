class UberZeit::TimeTypeCalculators::PikettBonus
  BONUS_FACTOR = 0.1
  BONUS_ACTIVE = { ends: 6, starts: 23 }

  def self.factor
    BONUS_FACTOR
  end

  def self.description
    'Calculates the bonus for work during pikett'.freeze
  end

  def self.name
    'Nine Pikett Bonus'.freeze
  end

  def initialize(time_chunk)
    @time_chunk = time_chunk
  end

  def result
    morning_window_bonus + evening_window_bonus + midnight_spanning_window_bonus
  end

  private
  def morning_window_bonus
    bonus_for_window(morning_window(@time_chunk.starts))
  end

  def evening_window_bonus
    bonus_for_window(evening_window(@time_chunk.starts))
  end

  def midnight_spanning_window_bonus
    return 0 if @time_chunk.starts.day == @time_chunk.ends.day
    bonus_for_window(morning_window(@time_chunk.starts + 1.day))
  end

  def bonus_for_window(window)
    return 0 unless time_chunk_intersects_window?(window)
    window_and_time_chunk_intersection(window).duration * BONUS_FACTOR
  end

  def morning_window(date)
    morning_starts = date.change(hour: 0, minute: 0)
    morning_ends = morning_starts.change(hour: BONUS_ACTIVE[:ends])
    morning_starts..morning_ends
  end

  def evening_window(date)
    evening_starts = date.change(hour: BONUS_ACTIVE[:starts], minute: 0)
    evening_ends = (evening_starts + 1.day).change(hour: 0)
    evening_starts..evening_ends
  end

  def window_and_time_chunk_intersection(window)
    window.intersect(@time_chunk.range)
  end

  def time_chunk_intersects_window?(window)
    !!window_and_time_chunk_intersection(window)
  end

end
