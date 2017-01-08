class LocationAwareController < ApplicationController

  protected

  def location_params
    params[:latlng].split(',')
  end

  private

  def check_latlng
    lat, lng = location_params
    latlng_are_valid = lat && lng && (lat =~ /[0-9\-\.]+/) && (lng =~ /[0-9\-\.]+/)
    render :nothing => true, :status => 404 unless latlng_are_valid
  end

end