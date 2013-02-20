module AfterLoginHelper
  def after_login(id)
    LdapSync.sync_person(id)
    current_user.ensure_timesheet_and_employment_exist
  end
end