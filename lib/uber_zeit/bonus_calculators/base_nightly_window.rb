module UberZeit::BonusCalculators::BaseNightlyWindow

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def factor
      self::FACTOR
    end

    def description
      self::DESCRIPTION
    end

    def name
      self::NAME
    end

    def active
      self::ACTIVE
    end
  end

  module InstanceMethods
    def initialize(time_entry)
      @time_entry = time_entry
    end

    def result
      morning_window_bonus + evening_window_bonus + midnight_spanning_window_bonus
    end

    private
    def morning_window_bonus
      bonus_for_window(morning_window(@time_entry.starts))
    end

    def evening_window_bonus
      bonus_for_window(evening_window(@time_entry.starts))
    end

    def midnight_spanning_window_bonus
      return 0 if @time_entry.starts.day == @time_entry.ends.day
      bonus_for_window(morning_window(@time_entry.starts + 1.day))
    end

    def bonus_for_window(window)
      return 0 unless time_entry_intersects_window?(window)
      window_and_time_entry_intersection(window).duration * self.class.factor
    end

    def morning_window(date)
      morning_starts = date.change(hour: 0, minute: 0)
      morning_ends = morning_starts.change(hour: self.class.active[:ends])
      morning_starts..morning_ends
    end

    def evening_window(date)
      evening_starts = date.change(hour: self.class.active[:starts], minute: 0)
      evening_ends = (evening_starts + 1.day).change(hour: 0)
      evening_starts..evening_ends
    end

    def window_and_time_entry_intersection(window)
      window.intersect(@time_entry.range)
    end

    def time_entry_intersects_window?(window)
      !!window_and_time_entry_intersection(window)
    end
  end

end

