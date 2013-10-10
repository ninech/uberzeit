class Reports::Absences::AbsenceController < ApplicationController

  before_filter :set_team
  before_filter :set_teams
  before_filter :set_year

  def year
    @selected_teams = @team.nil? ? Team.scoped : [@team]

    time_spans_with_scopes = TimeSpan
      .with_date_in_year(@year)
      .for_team(@selected_teams)
      .absences

    @result = time_spans_with_scopes.duration_in_work_day_sum_per_user_and_time_type
    @total = time_spans_with_scopes.duration_in_work_day_sum_per_time_type

    render :table
  end

  def month
    @selected_teams = @team.nil? ? Team.scoped : [@team]
    @month = params[:month].to_i

    time_spans_with_scopes = TimeSpan
      .with_date_in_year_and_month(@year, @month)
      .for_team(@selected_teams)
      .absences

    @result = time_spans_with_scopes.duration_in_work_day_sum_per_user_and_time_type
    @total = time_spans_with_scopes.duration_in_work_day_sum_per_time_type

    render :table
  end

  def calendar
    @month = params[:month].to_i
    @users = @team || User.all
    @range = UberZeit.month_as_range(@year, @month)
    @days = @range.to_a

    @public_holidays = Hash[@days.collect { |day| [day, PublicHoliday.with_date(day)] }]
    @work_days = Hash[@days.collect { |day| [day, UberZeit.is_weekday_a_workday?(day)] }]

    @absences = {}
    @users.each do |user|
      @absences[user] ||= {}

      find_time_chunks = FindTimeChunks.new(user.absences)
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
    @teams = Team.scoped
  end

  def set_year
    @year = params[:year].to_i
  end
end
