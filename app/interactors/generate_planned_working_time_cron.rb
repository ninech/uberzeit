class GeneratePlannedWorkingTimeCron
  def run
    years.each do |year|
      users.each do |user|
        Rails.logger.info ":generate:planned_working_time Calculating year #{year} for user #{user.uid}"
        Day.create_or_regenerate_days_for_user_and_year!(user, year)
      end
    end
  end

  def years
    [current_year, current_year + 1]
  end

  def current_year
    @current_year ||= Time.now.year
  end

  def users
    @users ||= User.all
  end
end

