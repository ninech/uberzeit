class Reports::WorkController < Reports::BaseController

  authorize_resource class: false

  def show
    @range = if @month
               UberZeit.month_as_range(@year, @month)
             else
               UberZeit.year_as_range(@year)
             end

    render :table
  end

end
