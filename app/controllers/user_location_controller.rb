class UserLocationController < LocationAwareController

  before_action :check_latlng, only: [:create]

  def index
    location = UserLocation.for_user(current_user)
    if location
      render json: {lat: location.latitude, lon: location.longitude}
    else
      render json: {error: 'No location stored'}, status: :unprocessable_entity
    end
  end

  def create
    lat, lng = location_params.map { |loc| loc.to_f.round(5) }
    location = UserLocation.for_user(current_user)

    if location
      location.longitude = lng
      location.latitude = lat
    else
      attribs = {user: current_user, latitude: lat, longitude: lng}
      location = UserLocation.new(attribs)
    end

    if location.save
      render json: {result: 'success'}
    else
      render json: {result: 'error'}, status: :unprocessable_entity
    end
  end

  def nearby
    lat, lng = location_params.map { |loc| loc.to_f }
    users = UserLocation.fresh.close_to(lat, lng, 500).to_a
    render json: {users: users}
  end


  def destroy
    location = UserLocation.for_user(current_user)
    if location
      render json: {result: !!location.destroy}
    else
      render json: {result: true}
    end

  end
end