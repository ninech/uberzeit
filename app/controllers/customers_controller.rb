class CustomersController < ApplicationController
  load_and_authorize_resource :customer

  def index
    params[:page] ||= 1
    @customers = @customers.page params[:page]
  end

  def new
  end

  def create
    @customer = Customer.new(params[:customer])
    if @customer.save
      redirect_to customers_path, flash: {success: t('model_successfully_created', model: Customer.model_name.human)}
    else
      render :new
    end
  end

  def update
    if @customer.update_attributes(params[:customer])
      redirect_to customers_path, flash: {success: t('model_successfully_updated', model: Customer.model_name.human)}
    else
      render :edit
    end
  end

  def destroy
    @customer.destroy
    redirect_to customers_path, flash: {success: t('model_successfully_deleted', model: Customer.model_name.human)}
  end
end

