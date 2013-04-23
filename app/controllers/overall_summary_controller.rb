class OverallSummaryController < ApplicationController
  before_filter :load_view
  before_filter :load_year
  before_filter :load_team
  before_filter :load_month

  def vacation
    @teams = Team.all
    summarize_overall = if @view == :month
                          SummarizeOverall.new(@year, @month, @team)
                        else
                          SummarizeOverall.new(@year, nil, @team)
                        end
    @rows = summarize_overall.vacation
  end

  private

  def load_year
    @year = params[:date][:year].to_i unless params[:date].blank? or params[:date][:year].blank?
    @year ||= Date.current.year
  end

  def load_month
    @month = params[:date][:month].to_i unless params[:date].blank? or params[:date][:month].blank?
    @month ||= Date.current.month
    @month_as_date = Date.new(@year, @month)
  end

  def load_view
    @view = params[:view] == 'month' ? :month : :year
  end

  def load_team
    @team = Team.find(params[:team]) unless params[:team].blank?
  end
end
