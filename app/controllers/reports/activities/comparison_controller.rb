class Reports::Activities::ComparisonController < Reports::BaseController

  load_and_authorize_resource :user

  def show
    #@range = UberZeit.month_as_range(@year, @month).last(10)
    @range = (Date.today - 10)..(Date.today)
    load_data_points_in_range
    render :table
  end

  private
  def load_data_points_in_range
    @data_points = { time_entries: [], activities: [] }
    @range.each do |date|
      if date > Date.today
        break
      end
      @data_points[:time_entries] << [(date.to_time.to_f * 1000.0).to_i, @user.time_sheet.effective_working_time_total(date).to_hours]
      @data_points[:activities] << [(date.to_time.to_f * 1000.0).to_i, (@user.activities.where(date: date).sum(:duration)/3600.0)]
    end
  end
end
