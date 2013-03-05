class RecurringEntriesController < ApplicationController
  before_filter :load_sheet

  def new
    @recurring_entry = RecurringEntry.new
  end

  def edit
    @recurring_entry = RecurringEntry.find(params[:id])
  end

  def create
    @recurring_entry = RecurringEntry.new(params[:recurring_entry])
    @time_sheet.recurring_entries << @recurring_entry
    if @recurring_entry.save
      redirect_to @time_sheet, :notice => 'Entry was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    @recurring_entry = RecurringEntry.find(params[:id])
    if @recurring_entry.update_attributes(params[:recurring_entry])
      redirect_to @time_sheet, :notice => 'Entry was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @recurring_entry = RecurringEntry.find(params[:id])
    if @recurring_entry.destroy
      redirect_to @time_sheet, :notice => 'Entry was successfully deleted.'
    else
      render :action => 'edit'
    end
  end 

  private

  def load_sheet
    @time_sheet = TimeSheet.find(params[:time_sheet_id]) unless params[:time_sheet_id].blank?
  end

end
