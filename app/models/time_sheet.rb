class TimeSheet < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  has_many :time_entries
  has_many :absences
  has_many :timers

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
    calculator = CalculatePlannedWorkingTime.new(user, date_or_range)
    calculator.total
  end

  def overtime(date_or_range)
    CalculateOvertime.new(self, date_or_range).total
  end

  def vacation(year)
    current_year = Time.current.beginning_of_year.to_date
    range = (current_year...current_year + 1.year)
    total(range, TimeType.vacation)
  end

  def total_reedemable_vacation(year)
    vacation = CalculateTotalRedeemableVacation.new(user, year)
    vacation.total_redeemable_for_year
  end

  def remaining_vacation(year)
    total_reedemable_vacation(year) - vacation(year)
  end
end
