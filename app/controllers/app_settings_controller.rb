class AppSettingsController < ApplicationController

  def index
    render json: current_user.app_settings
  end

  def create
    current_user.app_settings = defaults.merge(app_setting_params)

    if current_user.save
      render json: current_user.app_settings
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  private

  def defaults
    {location_sharing: false, notifications: false, units: 'imperial'}
  end


  def app_setting_params
    params.require(:app_setting).permit(:location_sharing, :notifications, :units)
  end
end
