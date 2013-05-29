class PublicHolidaysController < ApplicationController
  load_and_authorize_resource

  def index
    authorize! :manage, PublicHoliday

    @year = (params[:year] || session[:year] || Time.current.year).to_i
    session[:year] = @year

    year_range = UberZeit.year_as_range(@year)
    @public_holidays = @public_holidays.where('start_date <= ? AND end_date >= ?', year_range.max, year_range.min)
  end

  def new
  end

  def edit
  end

  def create
    @public_holiday = PublicHoliday.new(params[:public_holiday])
    @public_holiday.end_date = @public_holiday.start_date
    if @public_holiday.save
      redirect_to public_holidays_path, flash: {success: t('model_successfully_created', model: PublicHoliday.model_name.human)}
    else
      render :action => 'new'
    end
  end

  def update
    @public_holiday = PublicHoliday.find(params[:id])
    params[:public_holiday][:end_date] = params[:public_holiday][:start_date]
    if @public_holiday.update_attributes(params[:public_holiday])
      redirect_to public_holidays_path, flash: {success: t('model_successfully_updated', model: PublicHoliday.model_name.human)}
    else
      render :action => 'edit'
    end
  end

  def destroy
    @public_holiday = PublicHoliday.find(params[:id])
    if @public_holiday.destroy
      redirect_to public_holidays_path, flash: {success: t('model_successfully_deleted', model: PublicHoliday.model_name.human)}
    else
      render :action => 'edit'
    end
  end
end

