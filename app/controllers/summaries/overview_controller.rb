class Summaries::OverviewController < ApplicationController

  load_and_authorize_resource :user

  def index
    time_sheet = @user.current_time_sheet
    @uberstunden = time_sheet.overtime(Date.today.at_beginning_of_year..Date.today)

    month = Date.today.at_beginning_of_month..Date.today.at_end_of_month
    planned_work = time_sheet.planned_work(month)
    remaining_work = -1 * time_sheet.overtime(month)

    @month_percent_done = 100 * (planned_work - remaining_work) / planned_work
    @month_total_work = planned_work - remaining_work

    @personal_absences = []
    @team_absences = []

    @vacation_redeemed = 5.work_days
    @vacation_remaining = 20.work_days
  end
end
