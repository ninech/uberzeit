class Summaries::OverviewController < ApplicationController
  include
  load_and_authorize_resource :user

  def index
    time_sheet = @user.current_time_sheet

    @uberzeit = time_sheet.overtime(range_of_year_till_yesterday)

    overtime_till_today = time_sheet.overtime(range_of_current_month_till_today)
    planned_work_till_today = time_sheet.planned_work(range_of_current_month_till_today)
    accomplished_work_till_today = overtime_till_today + planned_work_till_today

    planned_work_whole_month = time_sheet.planned_work(range_of_current_month)

    @month_total_work = accomplished_work_till_today
    @month_percent_done = 100 * @month_total_work / planned_work_whole_month

    @personal_absences = get_personal_absences
    @team_absences = Hash[get_team_absences.sort_by { |date, _| date }]

    @vacation_redeemed = time_sheet.vacation(current_year)
    @vacation_remaining = time_sheet.remaining_vacation(current_year)
  end

  private

  def find_absences
    @find_absences ||= FindAbsences.new(current_user, range_of_absences)
  end

  def get_personal_absences
    find_absences.personal_absences
  end

  def get_team_absences
    find_absences.team_absences
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

  def current_year
    Date.today.year
  end
end
