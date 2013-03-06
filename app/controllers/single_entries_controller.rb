class SingleEntriesController < ApplicationController

  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :single_entry, through: :time_sheet

  def new
  end

  def edit
  end

  def create
    if @single_entry.save
      redirect_to @time_sheet, :notice => 'Entry was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    if @single_entry.update_attributes(params[:single_entry])
      redirect_to @time_sheet, :notice => 'Entry was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @single_entry.destroy
      redirect_to @time_sheet, :notice => 'Entry was successfully deleted.'
    else
      render :action => 'edit'
    end
  end
end
