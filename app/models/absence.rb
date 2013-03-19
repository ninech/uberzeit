class Absence < ActiveRecord::Base
  include CommonEntry

  attr_accessible :start_date, :end_date, :first_half_day, :second_half_day, :daypart

  validates_presence_of :start_date, :end_date

  validates_datetime :start_date
  validates_datetime :end_date, on_or_after: :start_date

  def self.nonrecurring_entries_in_range(range)
    date_range = range.to_date_range
    nonrecurring_entries.find(:all, conditions: ['(start_date <= ? AND end_date >= ?)', date_range.max, date_range.min])
  end

  def whole_day?
    # true when both or none of the flags is set
    not first_half_day? and not second_half_day?
  end

  def first_half_day?
    !!first_half_day and not !!second_half_day
  end

  def second_half_day?
    !!second_half_day and not !!first_half_day
  end

  def starts
    start_date
  end

  def ends
    end_date
  end

  def daypart
    case
    when whole_day?
      :whole_day
    when first_half_day?
      :first_half_day
    when second_half_day?
      :second_half_day
    end
  end

  def daypart=(value)
    case value.to_sym
    when :whole_day
      self.first_half_day = true
      self.second_half_day = true
    when :first_half_day
      self.first_half_day = true
      self.second_half_day = false
    when :second_half_day
      self.first_half_day = false
      self.second_half_day = true
    end
  end

  def time_range_for_date(date)
    time_start = date.midnight
    time_end = date.midnight + 1.day

    time_end = time_end - 12.hours if first_half_day?
    time_start = time_start + 12.hours if second_half_day?

    (time_start..time_end)
  end

  def duration_in_days
    (end_date - start_date).to_i
  end

  def occurrences_as_time_ranges(date_or_range)
    # for date entries we have to generate a occurrence range for each day (half days are not continuous)
    occurrences(date_or_range).collect do |start_time|
      date_range = range_for_other_start_time(start_time)
      date_range.collect { |day| time_range_for_date(day) }
    end.flatten
  end

  private

  def range_for_other_start_time(other_start_time)
    other_start_date = other_start_time.to_date
    (other_start_date..other_start_date+duration_in_days)
  end

end

