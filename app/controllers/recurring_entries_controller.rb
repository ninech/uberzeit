class RecurringEntriesController < ApplicationController

  before_filter :load_sheet

  def new
    @entry = RecurringEntry.new
  end

  def edit
    @entry = RecurringEntry.find(params[:id])
  end

  def create
    @entry = RecurringEntry.new(params[:recurring_entry])
    @sheet.recurring_entries << @entry
    if @entry.save
      redirect_to @sheet, :notice => 'Entry was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    @entry = RecurringEntry.find(params[:id])
    if @entry.update_attributes(params[:recurring_entry])
      redirect_to @sheet, :notice => 'Entry was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @entry = RecurringEntry.find(params[:id])
    if @entry.destroy
      redirect_to @sheet, :notice => 'Entry was successfully deleted.'
    else
      render :action => 'edit'
    end
  end

  private

  def load_sheet
    @sheet = TimeSheet.find(params[:time_sheet_id]) unless params[:time_sheet_id].blank?
  end

end
