class SessionsController < ApplicationController

  def new
    redirect_to Rails.env.development? ? '/auth/developer' : '/auth/cas'
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.find_by_uid(auth['uid'])
    user.ensure_timesheet_and_employment_exist
    sign_in(user)
    redirect_to time_sheet_path(user.time_sheets.last)
  end
end
