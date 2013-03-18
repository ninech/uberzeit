class TimeEntriesController < ApplicationController
  load_and_authorize_resource :time_sheet
  authorize_resource :time_entry, through: :time_sheet

  def new
  end

  def edit
    @entry = TimeEntry.find(params[:id])
    @time_types = TimeType.find_all_by_is_work(true)

    render 'edit', layout: false
  end

  def create
    @time_types = TimeType.find_all_by_is_work(true)

    if params[:time_entry][:to_time].blank?
      @entry = @time_sheet.build_timer(params[:time_entry].except(:to_time))
      @entry.save
    else
      @entry = @time_sheet.time_entries.new(params[:time_entry])
      @entry.save
    end

    render json: @entry.errors
  end

  def update
    @time_entry = TimeEntry.find(params[:id])

    if params[:time_entry][:to_time].blank?
      @timer = @time_sheet.build_timer(params[:time_entry].except(:to_time))
      @timer.save
      @time_entry.destroy

      render json: @timer.errors
    else
      @time_entry.update_attributes(params[:time_entry])
      render json: @time_entry.errors
    end
  end

  def destroy
    if @time_entry.destroy
      redirect_to @time_sheet, :notice => 'Entry was successfully deleted.'
    else
      render :action => 'edit'
    end
  end

  def exception_date
    rs = @time_entry.recurring_schedule
    rs.exception_dates.build(date: params[:date])
    rs.save!
    redirect_to @time_sheet, :notice => 'Exception date successfully added.'
  end
end
