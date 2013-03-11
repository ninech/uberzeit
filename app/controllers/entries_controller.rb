class EntriesController < ApplicationController

  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :entry, through: :time_sheet

  def new
  end

  def edit
  end

  def create
    if @entry.to_type.save
      redirect_to @time_sheet, :notice => 'Entry was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    if @entry.to_type.update_attributes(params[:entry])
      redirect_to @time_sheet, :notice => 'Entry was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @entry.destroy
      redirect_to @time_sheet, :notice => 'Entry was successfully deleted.'
    else
      render :action => 'edit'
    end
  end
end
