class TimeSheet
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # returns time chunks (which are limited to the given date or range)
  def find_chunks(date_or_range, time_types = TimeType.scoped)
    entries = [user.time_entries.where(time_type_id: time_types), user.absences.where(time_type_id: time_types)]

    find_chunks = FindTimeChunks.new(entries)
    find_chunks.in_range(date_or_range)
  end

  def total(date_or_range, time_types = TimeType.scoped)
    user.time_spans.date_between(date_range(date_or_range)).where(time_type_id: time_types).sum(:duration)
  end

  def overtime(date_or_range)
    bonus(date_or_range) + working_time_total(date_or_range) - planned_working_time(date_or_range)
  end

  def bonus(date_or_range, time_types = TimeType.scoped)
    user.time_spans.date_between(date_range(date_or_range)).where(time_type_id: time_types).sum(:duration_bonus)
  end

  def planned_working_time(date_or_range)
    FetchPlannedWorkingTime.new(user, date_range(date_or_range)).total
  end

  def vacation(year)
    range = UberZeit.year_as_range(year)
    user.time_spans.date_between(range).joins(:time_type).where(time_types: {is_vacation: true}).sum(:credited_duration)
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
    timers_in_range = user.time_entries.timers_only.select { |timer| range.intersects_with_duration?(timer.range) }
    timers_in_range.inject(0) { |sum,timer| sum + timer.duration(range) }
  end

  def working_time_total(date_or_range)
    user.time_spans.date_between(date_or_range).working_time.credited_duration_sum
  end

  def working_time_by_type(date_or_range)
    user.time_spans.date_between(date_or_range).working_time.credited_duration_sum_per_time_type
  end

  def effective_working_time_total(date_or_range)
    user.time_spans.date_between(date_or_range).effective_working_time.credited_duration_sum
  end

  def effective_working_time_by_type(date_or_range)
    user.time_spans.date_between(date_or_range).effective_working_time.credited_duration_sum_per_time_type
  end

  def absences_total(date_or_range)
    user.time_spans.date_between(date_or_range).absences.credited_duration_sum
  end

  def absences_by_type(date_or_range)
    user.time_spans.date_between(date_or_range).absences.credited_duration_sum_per_time_type
  end

  def adjustments_total(date_or_range)
    user.time_spans.date_between(date_or_range).adjustments.credited_duration_sum
  end

  def adjustments_by_type(date_or_range)
    user.time_spans.date_between(date_or_range).adjustments.credited_duration_sum_per_time_type
  end

  private
  def date_range(date_or_range)
    date_or_range.to_range.to_date_range
  end
end
