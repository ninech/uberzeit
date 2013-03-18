class RecurringSchedule < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :enterable, polymorphic: true

  attr_accessible   :active, :ends, :ends_counter, :ends_date, :enterable, :weekly_repeat_interval

  ENDING_CONDITIONS = %w(counter date)

  validates_inclusion_of :ends, in: ENDING_CONDITIONS

  validates_numericality_of :weekly_repeat_interval, greater_than: 0
  validates_numericality_of :ends_counter, greater_than: 0, if: :ends_on_counter?

  validates_date :ends_date, if: :ends_on_date?

  def active?
    !!active
  end

  def entry
    enterable
  end

  def ends_on_date?
    ends == 'date'
  end

  def ends_on_counter?
    ends == 'counter'
  end

  def start_date
    entry.starts.to_date
  end

  def start_time
    if entry.starts.kind_of?(Date)
      entry.starts.midnight
    else
      entry.starts
    end
  end

  def end_date
    if ends_on_counter?
      start_date + interval.to_days * (ends_counter - 1)
    elsif ends_on_date?
      ends_date.to_date
    else
      nil
    end
  end

  def range
    (start_date..end_date)
  end

  def interval
    weekly_repeat_interval.weeks
  end

  def duration
    entry.duration
  end

  def occurrences(date_or_range)
    occurrences_date_range = date_or_range.to_range.to_date_range
    recurring_schedule_date_range = self.range.to_date_range

    occurrences = []

    cursor = recurring_schedule_date_range.min
    while cursor <= recurring_schedule_date_range.max
      occurrence_start_time = start_time.change(year: cursor.year, month: cursor.month, day: cursor.day)
      occurrence_end_time = occurrence_start_time + duration

      range = (occurrence_start_time..occurrence_end_time)
      if range.intersects_with_duration?(occurrences_date_range)
        occurrences << occurrence_start_time
      end

      cursor += interval
    end

    occurrences
  end

  def occurring?(date_or_range)
    occurrences(date_or_range).any?
  end
end
