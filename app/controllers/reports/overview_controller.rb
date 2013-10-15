class Reports::OverviewController < ApplicationController
  include AbsencesHelper

  load_and_authorize_resource :user

  def index
    @uberzeit = @user.time_sheet.overtime(range_of_year_till_yesterday)

    overtime_till_today = @user.time_sheet.overtime(range_of_current_month_till_today)
    planned_work_till_today = @user.time_sheet.planned_working_time(range_of_current_month_till_today)
    accomplished_work_till_today = overtime_till_today + planned_work_till_today

    planned_work_whole_month = @user.time_sheet.planned_working_time(range_of_current_month)

    @month_total_work = accomplished_work_till_today
    if planned_work_whole_month == 0
      @month_percent_done = 100
    else
      @month_percent_done = 100 * @month_total_work / planned_work_whole_month
    end

    @personal_absences = find_personal_absences
    @team_absences = Hash[find_team_absences.sort_by { |date, _| date }]

    @vacation_redeemed = @user.time_sheet.redeemed_vacation(range_of_year)
    @vacation_remaining = @user.time_sheet.remaining_vacation(current_year)
  end

  private

  def find_personal_absences
    FindDailyAbsences.new(current_user, range_of_absences).result
  end

  def find_team_absences
    FindDailyAbsences.new(other_team_members(current_user), range_of_absences).result
  end

  def range_of_absences
    @range_of_absences ||= Date.today..Date.today+7.days
  end

  def range_of_current_month
    @range_of_current_month ||= Date.today.at_beginning_of_month..Date.today.at_end_of_month
  end

  def range_of_current_month_till_today
    @range_of_current_month_till_today ||= Date.today.at_beginning_of_month..Date.today
  end

  def range_of_year_till_yesterday
    @range_of_year_till_yesterday ||= Date.today.at_beginning_of_year..Date.yesterday
  end

  def range_of_year
    @range_of_year ||= Date.today.at_beginning_of_year..Date.today.at_end_of_year
  end

  def current_year
    Date.today.year
  end

end
