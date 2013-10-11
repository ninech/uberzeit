class Reports::Vacation::VacationController < Reports::BaseController

  authorize_resource class: false

  def year
  end

  def month
  end

end
