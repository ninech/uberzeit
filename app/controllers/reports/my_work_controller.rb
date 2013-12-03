class Reports::MyWorkController < Reports::BaseController

  load_and_authorize_resource :user

  def show
    if @year.nil?
      redirect_to action: :show, year: Time.current.year, month: Time.current.month
      return
    end

    if @month
      @range = UberZeit.month_as_range(@year, @month)
      @buckets = UberZeit.range_to_buckets(@range, 1.week, @range.min.beginning_of_week)
    else
      @range = UberZeit.year_as_range(@year)
      @buckets = UberZeit.range_to_buckets(@range, 1.month, @range.min)
    end

    render :table
  end

end
