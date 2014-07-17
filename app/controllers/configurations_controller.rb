class ConfigurationsController < ApplicationController
  authorize_resource class: false

  before_filter :load_configuration

  def edit
  end

  def update
    if @configuration.update_attributes(params[:configuration])
      redirect_to edit_configuration_path, flash: {
        success: t('model_successfully_updated',
                   model: ::Configuration.model_name.human)
      }
    else
      render :edit
    end
  end

  private

  def load_configuration
    @configuration = ::Configuration.new
  end
end
