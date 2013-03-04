module AfterLoginHelper
  def after_login(user)
    LdapSync.sync_person(user.uid)
    current_user.ensure_timesheet_and_employment_exist
  end
end
