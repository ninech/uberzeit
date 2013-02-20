class SessionsController < ApplicationController
  def new
    if signed_in?
      # redirect to his time sheet
      redirect_to user_time_sheet_path(current_user, current_user.sheets.last)
    end
  end
end
