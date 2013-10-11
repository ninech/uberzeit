class Reports::Absences::AbsenceController < Reports::BaseController
  def year
    time_spans_with_scopes = TimeSpan.where(user_id: @users)
      .with_date_in_year(@year)
      .absences_with_adjustments

    @result = time_spans_with_scopes.duration_in_work_day_sum_per_user_and_time_type
    @total = time_spans_with_scopes.duration_in_work_day_sum_per_time_type

    render :table
  end

  def month
    time_spans_with_scopes = TimeSpan.where(user_id: @users)
      .with_date_in_year_and_month(@year, @month)
      .absences_with_adjustments

    @result = time_spans_with_scopes.duration_in_work_day_sum_per_user_and_time_type
    @total = time_spans_with_scopes.duration_in_work_day_sum_per_time_type

    render :table
  end

  def calendar
    @range = UberZeit.month_as_range(@year, @month)

    @public_holidays = Hash[@range.collect { |day| [day, PublicHoliday.with_date(day)] }]
    @work_days = Hash[@range.collect { |day| [day, UberZeit.is_weekday_a_workday?(day)] }]
    @absences = TimeSpan.absences.with_date(@range).where(user_id: @users).group_by { |ts| [ts.user_id, ts.date] }
  end
end
