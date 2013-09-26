class GeneratePlannedWorkingTimesForUserAndYear

  def initialize(user, year)
    @user = user
    @year = year
  end

  def run
    remove_existing_entries
    generate_temporary_working_time_entries
    fix_temporary_working_entries_for_public_holidays
    true
  end

  private
  def remove_existing_entries
    @user.days.in(year_as_range).destroy_all
  end

  def generate_temporary_working_time_entries
    year_as_range.each do |day|
      temporary_working_time = if UberZeit.is_weekday_a_workday?(day) && employment_for_day = employments_in_year.find { |employment| employment.on_date?(day) }
                                 employment_for_day.expected_daily_work_hours_in_seconds
                               else
                                 0
                               end
      @user.days.create!(date: day, planned_working_time: temporary_working_time)
    end
  end

  def fix_temporary_working_entries_for_public_holidays
    PublicHoliday.in(year_as_range).each do |public_holiday|
      @user.generate_planned_working_time_for_date!(public_holiday.date)
    end
  end

  def year_as_range
    @year_as_range ||= Date.civil(@year, 1, 1)..Date.civil(@year, 12, 31)
  end

  def employments_in_year
    @employments_in_year ||= @user.employments.between(year_as_range).to_a
  end

end
