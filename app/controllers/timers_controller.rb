class TimersController < ApplicationController
  load_and_authorize_resource :time_sheet
  authorize_resource :timer, through: :time_sheet

  def new
  end

  def edit
    @timer = Timer.find(params[:id])
    @time_types = TimeType.find_all_by_is_work(true)

    render 'edit', layout: false
  end

  def update
    @timer = Timer.find(params[:id])
    if params[:timer][:end_time].blank?
      @timer.update_attributes(params[:timer].except(:end_time))
    else
      @timer.stop
    end
    render json: {}
  end

  def destroy
    @timer = Timer.find(params[:id])
    @timer.destroy
    render json: {}
  end
end
