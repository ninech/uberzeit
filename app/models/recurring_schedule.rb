class RecurringSchedule < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :enterable, polymorphic: true

  has_many :exception_dates

  attr_accessible   :active, :ends, :ends_counter, :ends_date, :enterable, :weekly_repeat_interval

  ENDING_CONDITIONS = %w(counter date)

  validates_inclusion_of :ends, in: ENDING_CONDITIONS, if: :active?

  validates_numericality_of :weekly_repeat_interval, greater_than: 0, if: :active?
  validates_numericality_of :ends_counter, greater_than: 0, if: lambda { active? && ends_on_counter? }

  validates_date :ends_date, if: lambda { active? && ends_on_date? }

  validates_uniqueness_of :enterable_id, scope: :enterable_type

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

  def start_time_of_associated_entry
    if entry.starts.kind_of?(Date) # convert it to time for date entries
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

  def has_exception_date_in_range?(exceptions, range)
    range.to_date_range.any? { |date| not exceptions[date.to_s].nil? }
  end

  def occurrences(date_or_range)
    occurrences_date_range = date_or_range.to_range.to_date_range
    recurring_schedule_date_range = self.range.to_date_range

    exceptions_in_range = exception_dates.in(recurring_schedule_date_range)
    exceptions = exceptions_in_range.each_with_object({}) do |exception, hash|
      hash[exception.date.to_s] = exception
    end

    occurrences = []

    cursor = recurring_schedule_date_range.min
    while cursor <= recurring_schedule_date_range.max && cursor <= occurrences_date_range.max
      unless has_exception_date_in_range?(exceptions, cursor...cursor+interval)
        occurrence_start_time = start_time_of_associated_entry.change(year: cursor.year, month: cursor.month, day: cursor.day)
        occurrence_end_time = occurrence_start_time + duration

        occurrence_range = (occurrence_start_time..occurrence_end_time)
        if occurrence_range.intersects_with_duration?(occurrences_date_range)
          occurrences << occurrence_start_time
        end
      end

      cursor += interval
    end

    occurrences
  end

  def occurring?(date_or_range)
    occurrences(date_or_range).any?
  end
end
