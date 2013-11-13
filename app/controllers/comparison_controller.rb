class ComparisonController < ApplicationController

  load_and_authorize_resource :user

  def show
    @date = Date.parse(params[:date] || Date.current)
    @range = (@date.beginning_of_week)..(@date.end_of_week)
    load_data_points_in_range
  end

  private
  def load_data_points_in_range
    @data_points = { time_entries: [], activities: [] }
    @range.each do |date|
      @data_points[:time_entries] << [(date.to_time.to_f * 1000.0).to_i, @user.time_sheet.effective_working_time_total(date).to_hours]
      @data_points[:activities] << [(date.to_time.to_f * 1000.0).to_i, (@user.activities.where(date: date).sum(:duration)/3600.0)]
    end
  end
end
