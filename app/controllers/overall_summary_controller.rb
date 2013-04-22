class OverallSummaryController < ApplicationController
  def vacation

    summarize_overall = SummarizeOverall.new(Date.current.year, Date.current.month)
    @rows = summarize_overall.vacation
    @month_date = Date.new(Date.current.year, Date.current.month)
  end
end
