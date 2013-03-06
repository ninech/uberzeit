class TimeSheetsController < ApplicationController

  load_and_authorize_resource

  respond_to :html

  def index
    respond_with(@time_sheets)
  end

  def show
    respond_with(@time_sheet)
  end
end
