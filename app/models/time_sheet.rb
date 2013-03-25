class TimeSheet < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  has_many :time_entries
  has_many :absences
  has_one :timer

  validates_presence_of :user

  # returns time chunks (which are limited to the given date or range)
  def find_chunks(date_or_range, time_types = TimeType.scoped)
    entries = [time_entries.where(time_type_id: time_types), absences.where(time_type_id: time_types)]

    find_chunks = FindTimeChunks.new(entries)
    find_chunks.in_range(date_or_range)
  end

  def work(date_or_range)
    CalculateWorkingTime.new(self, date_or_range).total
  end

  def total(date_or_range, time_types = TimeType.scoped)
    chunks = find_chunks(date_or_range, time_types)
    chunks.total
  end

  def planned_work(date_or_range)
    user.planned_work(date_or_range)
  end

  def overtime(date_or_range)
    CalculateOvertime.new(self, date_or_range).total
  end

  def vacation(year)
    current_year = Time.zone.now.beginning_of_year.to_date
    range = (current_year...current_year + 1.year)
    total(range, TimeType.vacation)
  end

  def remaining_vacation(year)
    user.vacation_available(year) - vacation(year)
  end

end
