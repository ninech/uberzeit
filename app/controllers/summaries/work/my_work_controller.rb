class Summaries::Work::MyWorkController < ApplicationController

  load_and_authorize_resource :user

  def year
    @year = params[:year].to_i
    @range = UberZeit.year_as_range(@year)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Work, [@user], @range, 1.month)

    @entries = @table.entries

    # special case for year overview: calculate running overtime
    running_overtime = 0
    @entries.each_pair do |range, users_summary|
      _, summary = users_summary.first
      running_overtime += summary[:overtime]
      summary[:running_overtime] = running_overtime
    end
  end

  def month
    @year = params[:year].to_i
    @month = params[:month].to_i
    @range = UberZeit.month_as_range(@year, @month)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Work, [@user], @range, 1.week, @range.min.monday)
    @entries = @table.entries
  end
end
