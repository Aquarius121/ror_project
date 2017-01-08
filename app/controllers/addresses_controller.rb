class AddressesController < ApplicationController

  def city
    result = JSON.parse open('app/assets/json/cities-per-state.json').read
    respond_to do |format|
      format.json { render json: result[params[:state]] }
    end
  end

  def cities
    data = JSON.parse open('app/assets/json/cities-per-state.json').read
    r = Regexp.new(params[:q], true)
    data = data.map do |state, cities|
      [state, cities.select { |city| city =~ r }]
    end.select do |state, cities|
      cities.length > 0
    end.map do |state, cities|
      cities.map { |city| {name: "#{city}, #{state}"} }
    end.flatten

    render json: data
  end

end
