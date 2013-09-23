## == Schema Information
##
## Table name: time_sheets
##
##  id         :integer          not null, primary key
##  user_id    :integer
##  created_at :datetime         not null
##  updated_at :datetime         not null
##  deleted_at :datetime
##
#

class TimeSheet
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # returns time chunks (which are limited to the given date or range)
  def find_chunks(date_or_range, time_types = TimeType.scoped)
    entries = [@user.time_entries.where(time_type_id: time_types), @user.absences.where(time_type_id: time_types)]

    find_chunks = FindTimeChunks.new(entries)
    find_chunks.in_range(date_or_range)
  end

  def total(date_or_range, time_types = TimeType.scoped)
    chunks = find_chunks(date_or_range, time_types)
    chunks.total
  end

  def overtime(date_or_range)
    CalculateOvertime.new(self, date_or_range).total
  end

  def bonus(date_or_range, time_types = TimeType.scoped)
    chunks = find_chunks(date_or_range, time_types)
    chunks.bonus
  end

  def planned_work(date_or_range)
    calculator = CalculatePlannedWorkingTime.new(date_or_range, @user)
    calculator.total
  end

  def vacation(year)
    range = UberZeit.year_as_range(year)
    redeemed = CalculateRedeemedVacation.new(@user, range)
    redeemed.total
  end

  def remaining_vacation(year)
    total_reedemable_vacation(year) - vacation(year)
  end

  def total_reedemable_vacation(year)
    vacation = CalculateTotalRedeemableVacation.new(user, year)
    vacation.total_redeemable_for_year
  end

  def duration_of_timers(date_or_range)
    range = date_or_range.to_range.to_date_range
    timers_in_range = @user.time_entries.timers_only.select { |timer| range.intersects_with_duration?(timer.range) }
    timers_in_range.inject(0) { |sum,timer| sum + timer.duration(range) }
  end

  def work(date_or_range)
    CalculateWorkingTime.new(self, date_or_range).total
  end
end
