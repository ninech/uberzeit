class DateEntriesController < ApplicationController
  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :date_entry, through: :time_sheet

  def new
    @date_entry.build_recurring_schedule
  end

  def edit
    @date_entry.build_recurring_schedule if @date_entry.recurring_schedule.nil?
  end

  def create
    if @date_entry.save
      redirect_to @time_sheet, :notice => 'Entry was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    if @date_entry.update_attributes(params[:date_entry])
      redirect_to @time_sheet, :notice => 'Entry was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @date_entry.destroy
      redirect_to @time_sheet, :notice => 'Entry was successfully deleted.'
    else
      render :action => 'edit'
    end
  end
end
