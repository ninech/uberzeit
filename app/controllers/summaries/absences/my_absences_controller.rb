class Summaries::Absences::MyAbsencesController < ApplicationController

  load_and_authorize_resource :user

  def year
    @year = params[:year].to_i
    @range = UberZeit.year_as_range(@year)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Absences, [@user], @range, 1.month)
    @entries = @table.entries

    # calculate remaining vacation days
    vacation_taken = @table.total(TimeType.vacation)
    vacation_total_redeemable = CalculateTotalRedeemableVacation.new(@user, @year).total_redeemable_for_year
    vacation_remaining = vacation_total_redeemable - vacation_taken

    @remaining = {TimeType.vacation => vacation_remaining}
  end

end
