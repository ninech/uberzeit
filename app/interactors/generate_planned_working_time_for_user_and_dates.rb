class GeneratePlannedWorkingTimeForUserAndDates

  def initialize(user, date_range)
    @user = user
    @date_range = date_range
  end

  def run
    remove_existing_entries

    total_per_date.each do |date, planned_working_time|
      @user.days.create!(date: date, planned_working_time: planned_working_time)
    end
  end

  private
  def remove_existing_entries
    @user.days.in(@date_range).destroy_all
  end

  def total_per_date
    CalculatePlannedWorkingTime.new(@date_range, @user).total_per_date
  end

end
