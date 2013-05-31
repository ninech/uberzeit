class Summaries::OverviewController < ApplicationController

  load_and_authorize_resource :user

  def index
    time_sheet = @user.current_time_sheet
    @uberstunden = time_sheet.overtime(Date.today.at_beginning_of_year..Date.yesterday)

    month = Date.today.at_beginning_of_month..Date.today.at_end_of_month
    planned_work = time_sheet.planned_work(month)
    remaining_work = -1 * time_sheet.overtime(month)

    @month_percent_done = 100 * (planned_work - remaining_work) / planned_work
    @month_total_work = planned_work - remaining_work

    absence_range = Date.today..Date.today+7.days

    @personal_absences = {}
    time_chunks_finder = FindTimeChunks.new(time_sheet.absences)
    time_chunks_finder.in_range(absence_range).each do |chunk|
      chunk.range.to_date_range.each do |date|
        @personal_absences[date] ||= []
        @personal_absences[date] << chunk
      end
    end

    time_sheets_from_team = TimeSheet.joins(:user => :teams).where(memberships: {team_id: @user.teams}).where('users.id != ?', @user)
    @team_absences = {}

    time_sheets_from_team.each do |ts|
      time_chunks_finder = FindTimeChunks.new(ts.absences)
      time_chunks_finder.in_range(absence_range).each do |chunk|
        chunk.range.to_date_range.each do |date|
          @team_absences[date] ||= []
          @team_absences[date] << {user: ts.user, chunk: chunk}
        end
      end
    end

    @team_absences = Hash[@team_absences.sort_by { |date, _| date }]

    @vacation_redeemed = time_sheet.vacation(Date.today.year)
    @vacation_remaining = time_sheet.remaining_vacation(Date.today.year)
  end
end
