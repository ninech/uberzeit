class Reports::Work::MyWorkController < ApplicationController

  load_and_authorize_resource :user

  before_filter :set_year

  def year
    @range = UberZeit.year_as_range(@year)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Work, [@user], @range, 1.month)

    # special case for year overview: calculate running overtime
    running_overtime = 0
    @table.entries.each_pair do |range, users_summary|
      _, summary = users_summary.first
      running_overtime += summary[:overtime]
      summary[:running_overtime] = running_overtime
    end
  end

  def month
    @month = params[:month].to_i
    @range = UberZeit.month_as_range(@year, @month)
    @table = Summarize::TableWithInterval.new(Summarize::Summarizer::Work, [@user], @range, 1.week, @range.min.monday)
  end

  private

  def set_year
    @year = params[:year].to_i
  end

end
