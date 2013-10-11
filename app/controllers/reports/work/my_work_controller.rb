class Reports::Work::MyWorkController < Reports::BaseController

  load_and_authorize_resource :user

  def year
    @range = UberZeit.year_as_range(@year)
    @buckets = UberZeit.range_to_buckets(@range, 1.month, @range.min)
    render :table
  end

  def month
    @range = UberZeit.month_as_range(@year, @month)
    @buckets = UberZeit.range_to_buckets(@range, 1.week, @range.min.beginning_of_week)
    render :table
  end

end
