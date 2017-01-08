json.array!(@shared_rides) do |shared_ride|
  json.extract! shared_ride, :id, :route_id, :user_id
  json.url shared_ride_url(shared_ride, format: :json)
end

