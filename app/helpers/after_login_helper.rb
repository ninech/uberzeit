module AfterLoginHelper
  def after_login(user)
    current_user.ensure_timesheet_and_employment_exist
  end
end
