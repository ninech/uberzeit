class FetchPlannedWorkingTime

  def initialize(user, range)
    @user = user
    @range = range
  end

  def total
    generate_missing_entries
    sum_over_range_from_database
  end

  private
  def generate_missing_entries
    # assume we have no gaps in the database
    if no_entry_in_the_database?
      generate_entries_for_range(first_day_requested..last_day_requested)
    else
      if first_day_in_database > first_day_requested
        generate_entries_for_range(first_day_requested...first_day_in_database)
      end

      if last_day_in_database < last_day_requested
        generate_entries_for_range((last_day_in_database + 1)..last_day_requested)
      end
    end
  end

  def generate_entries_for_range(range)
    Day.create_or_regenerate_days_for_user_and_range!(@user, range)
  end

  def sum_over_range_from_database
    @user.days.in(@range).sum(:planned_working_time)
  end

  def no_entry_in_the_database?
    first_day_in_database.nil?
  end

  def first_day_in_database
    @first_day_in_database ||= @user.days.minimum(:date)
  end

  def last_day_in_database
    @last_day_in_database ||= @user.days.maximum(:date)
  end

  def first_day_requested
    @range.min
  end

  def last_day_requested
    @range.max
  end

end
