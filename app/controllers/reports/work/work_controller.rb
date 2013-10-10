class Reports::Work::WorkController < Reports::BaseController

  authorize_resource class: false

  def year
    @range = UberZeit.year_as_range(@year)
    render :table
  end

  def month
    @range = UberZeit.month_as_range(@year, @month)
    render :table
  end

end
