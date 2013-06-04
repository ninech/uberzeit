class Summaries::OverviewController < ApplicationController

  load_and_authorize_resource :user

  def index
    time_sheet = @user.current_time_sheet

    @uberzeit = time_sheet.overtime(range_of_year_till_yesterday)

    planned_work = time_sheet.planned_work(range_of_current_month)
    remaining_work = -1 * time_sheet.overtime(range_of_current_month)

    @month_total_work = planned_work - remaining_work
    @month_percent_done = 100 * @month_total_work / planned_work

    @personal_absences = get_personal_absences
    @team_absences = Hash[get_team_absences.sort_by { |date, _| date }]

    @vacation_redeemed = time_sheet.vacation(current_year)
    @vacation_remaining = time_sheet.remaining_vacation(current_year)
  end

  private

  def get_personal_absences
    Hash.new.tap do |personal_absences|
      find_time_chunks(@user.current_time_sheet.absences, range_of_absences) do |date, chunk|
        personal_absences[date] ||= []
        personal_absences[date] << chunk
      end
    end
  end

  def get_team_absences
    Hash.new.tap do |team_absences|
      time_sheets_from_team.each do |ts|
        find_time_chunks(ts.absences, range_of_absences) do |date, chunk|
          team_absences[date] ||= []
          team_absences[date] << {user: ts.user, chunk: chunk}
        end
      end
    end
  end

  def find_time_chunks(entries, range)
    time_chunks_finder = FindTimeChunks.new(entries)
    time_chunks_finder.in_range(range).each do |chunk|
      chunk.range.to_date_range.each do |date|
        yield(date, chunk)
      end
    end
  end

  def range_of_absences
    @range_of_absences ||= Date.today..Date.today+7.days
  end

  def range_of_current_month
    @range_of_current_month ||= Date.today.at_beginning_of_month..Date.today.at_end_of_month
  end

  def range_of_year_till_yesterday
    @range_of_year_till_yesterday ||= Date.today.at_beginning_of_year..Date.yesterday
  end

  def current_year
    Date.today.year
  end

  def time_sheets_from_team
    @time_sheets_from_team ||= TimeSheet.joins(:user => :teams).where(memberships: {team_id: @user.teams}).where('users.id != ?', @user)
  end
end
