class GeneratePlannedWorkingTimeForUserAndDates

  def initialize(user, dates)
    @user = user
    @dates = dates
  end

  def run
    remove_existing_entries

    totals_per_date.each do |date, planned_working_time|
      @user.days.create!(date: date, planned_working_time: planned_working_time)
    end
  end

  private
  def remove_existing_entries
    @user.days.in(@dates).destroy_all
  end

  def totals_per_date
    CalculatePlannedWorkingTime.new(@dates, @user).total_per_date
  end

end
