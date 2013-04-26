class Summaries::Absence::AbsenceController < ApplicationController

  before_filter :set_team
  before_filter :set_teams
  before_filter :set_year

  def year
    @table = Summarize::Table.new(Summarize::Summarizer::Absences, @team || User.all, UberZeit.year_as_range(@year))
  end

  def month
    @month = params[:month].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Absences, @team || User.all, UberZeit.month_as_range(@year, @month))
  end

  def calendar
    @month = params[:month].to_i
    @users = @team || User.all
    @range = UberZeit.month_as_range(@year, @month)
    @days = @range.to_a

    @public_holidays = Hash[@days.collect { |day| [day, PublicHoliday.on(day)] }]
    @work_days = Hash[@days.collect { |day| [day, UberZeit.is_weekday_a_workday?(day)] }]

    @absences = {}
    @users.each do |user|
      @absences[user] ||= {}
      next if user.current_time_sheet.nil?

      find_time_chunks = FindTimeChunks.new(user.current_time_sheet.absences)
      find_time_chunks.in_range(@range).each do |chunk|
        chunk.range.to_date_range.each do |day|
          @absences[user][day] ||= []
          @absences[user][day] << chunk
        end
      end
    end
  end

  private

  def set_team
    @team = Team.find(params[:team_id]) unless params[:team_id].blank?
  end

  def set_teams
    @teams = Team.all
  end

  def set_year
    @year = params[:year].to_i
  end
end
