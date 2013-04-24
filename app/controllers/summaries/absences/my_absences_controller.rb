class Summaries::Absences::MyAbsencesController < ApplicationController

  load_and_authorize_resource :user

  def year
    @year = params[:year].to_i
    @range = UberZeit.year_as_range(@year)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Absences, [@user], @range, 1.month)
    @entries = @table.entries
  end

  def month
    @year = params[:year].to_i
    @month = params[:month].to_i
    @range = UberZeit.month_as_range(@year, @month)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Absences, [@user], @range, 1.week, @range.min.monday)
    @entries = @table.entries
  end
end
