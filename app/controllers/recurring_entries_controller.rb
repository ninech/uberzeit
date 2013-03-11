class RecurringEntriesController < ApplicationController

  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :recurring_entry, through: :time_sheet

  # def new
  # end

  # def edit
  # end

  # def create
  #   if @recurring_entry.save
  #     redirect_to @time_sheet, :notice => 'Entry was successfully created.'
  #   else
  #     render :action => 'new'
  #   end
  # end

  # def update
  #   if @recurring_entry.update_attributes(params[:recurring_entry])
  #     redirect_to @time_sheet, :notice => 'Entry was successfully updated.'
  #   else
  #     render :action => 'edit'
  #   end
  # end

  # def destroy
  #   if @recurring_entry.destroy
  #     redirect_to @time_sheet, :notice => 'Entry was successfully deleted.'
  #   else
  #     render :action => 'edit'
  #   end
  # end
end
