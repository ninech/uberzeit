class TimeSheetsController < ApplicationController
  def index
  end

  def show
    @sheet = TimeSheet.find(params[:id])
  end
end
