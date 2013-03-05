class SingleEntriesController < ApplicationController
  before_filter :load_sheet

  def new
    @single_entry = SingleEntry.new
  end

  def edit
    @single_entry = SingleEntry.find(params[:id])
  end

  def create
    @single_entry = SingleEntry.new(params[:single_entry])
    @time_sheet.single_entries << @single_entry
    if @single_entry.save
      redirect_to @time_sheet, :notice => 'Entry was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    @single_entry = SingleEntry.find(params[:id])
    if @single_entry.update_attributes(params[:single_entry])
      redirect_to @time_sheet, :notice => 'Entry was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @single_entry = SingleEntry.find(params[:id])
    if @single_entry.destroy
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
