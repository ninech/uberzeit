class GeneratePlannedWorkingTimeForUserAndDate

  def initialize(user, date)
    @user = user
    @date = date
  end

  def run
    planned_working_time = CalculatePlannedWorkingTime.new(@date, @user).total
    @user.days.find_by_date(@date).update_attribute(:planned_working_time, planned_working_time)
  end

end
