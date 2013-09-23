class Summaries::Activity::ComparisonController < ApplicationController

  load_and_authorize_resource :user

  before_filter :set_year, :set_month

  def index
    @range = UberZeit.month_as_range(@year, @month)
    load_data_points_in_range
  end

  private

  def set_year
    @year = params[:year].to_i
  end

  def set_month
    @month = params[:month].to_i
  end

  def load_data_points_in_range
    @data_points = { time_entries: [], activities: [] }
    @range.each do |date|
      if date > Date.today
        break
      end
      @data_points[:time_entries] << [(date.to_time.to_f * 1000.0).to_i, @user.time_sheet.total(date, TimeType.work).to_hours]
      @data_points[:activities] << [(date.to_time.to_f * 1000.0).to_i, (@user.activities.where(date: date).sum(:duration)/3600.0)]
    end
  end
end
