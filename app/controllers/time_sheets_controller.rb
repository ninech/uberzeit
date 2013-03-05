class TimeSheetsController < ApplicationController
  def index
    @time_sheets = TimeSheet.all
  end

  def show
    @time_sheet = TimeSheet.find(params[:id])
  end
end
