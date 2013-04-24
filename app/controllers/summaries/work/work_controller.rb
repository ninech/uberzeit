class Summaries::Work::WorkController < ApplicationController
  include SummaryHelper

  load_and_authorize_resource :user

  def year
    @year = params[:year].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Work, User.all, UberZeit.year_as_range(@year))
    @entries = @table.entries
  end

  def month
    @year = params[:year].to_i
    @month = params[:month].to_i
    @table = Summarize::Table.new(Summarize::Summarizer::Work, User.all, UberZeit.month_as_range(@year, @month))
    @entries = @table.entries
  end
end
