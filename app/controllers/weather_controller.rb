class WeatherController < LocationAwareController

  before_action :check_latlng, only: [:index]

  def index
    # coordinates = "#{params[:lat]},#{params[:lng]}"
    # barometer = Barometer.new(coordinates)
    # weather = barometer.measure
    # current_weather = weather.current
    cache_key = params[:latlng]

    current_weather = Rails.cache.fetch(cache_key, expires_in: 20.minutes) do
      lat, lng = params[:latlng].split(',')
      forecast = ForecastIO.forecast(lat, lng)
      forecast.currently
    end
    render json: {
               temp: current_weather.temperature,
               icon: current_weather.icon,
               condition: current_weather.summary
           }
  end

end
