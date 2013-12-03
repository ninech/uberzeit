class Reports::VacationController < Reports::BaseController

  authorize_resource class: false

  def show
    if @month
      render :month
    else
      render :year
    end
  end

end
