class Reports::Absences::MyAbsenceController < ApplicationController

  load_and_authorize_resource :user

  before_filter :set_year

  def year
    @range = UberZeit.year_as_range(@year)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Absences, [@user], @range, 1.month)

    # calculate remaining vacation days
    vacation_taken = @table.total(TimeType.vacation)
    vacation_total_redeemable = CalculateTotalRedeemableVacation.new(@user, @year).total_redeemable_for_year
    vacation_remaining = vacation_total_redeemable - vacation_taken

    @remaining = {TimeType.vacation => vacation_remaining}
  end

  def month
    @month = params[:month].to_i
    @range = UberZeit.month_as_range(@year, @month)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Absences, [@user], @range, 1.week, @range.min.monday)
  end

  private

  def set_year
    @year = params[:year].to_i
  end

end
