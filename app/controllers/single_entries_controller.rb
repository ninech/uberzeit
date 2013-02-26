class SingleEntriesController < ApplicationController
  before_filter :load_sheet

  def new
    @entry = SingleEntry.new
  end

  def edit
    @entry = SingleEntry.find(params[:id])
  end

  def create
    @entry = SingleEntry.new(params[:single_entry])
    #if params[:whole_day]
    #  ref_time = @entry.start_time
    #  @entry.start_time = Time.utc(ref_time.year, ref_time.month, ref_time.day)
    #  @entry.end_time = @entry.start_time + 24.hours
    #end
    
    @sheet.single_entries << @entry
    if @entry.save
      redirect_to @sheet, :notice => 'Entry was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    @entry = SingleEntry.find(params[:id])
    @entry.update_attributes(params[:single_entry])
    redirect_to @sheet, :notice => 'Entry was successfully updated.'
  end

  def destroy
    @entry = SingleEntry.find(params[:id])
    @entry.destroy
    
    redirect_to @sheet, :notice => 'Entry was successfully deleted.'
  end 

  private

  def load_sheet
    @sheet = TimeSheet.find(params[:time_sheet_id])
  end

end
