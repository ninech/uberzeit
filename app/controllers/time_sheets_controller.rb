class TimeSheetsController < ApplicationController
  def index
    @sheets = TimeSheet.all
  end

  def show
    @sheet = TimeSheet.find(params[:id])
  end
end
