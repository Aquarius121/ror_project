json.array!(@routes) do |route|
  json.extract! route, :title, :surface_id, :rating, :elevation, :ridedate, :description, :privacy_id, :condition_id
  json.url route_url(route, format: :json)
  json.updated_at route.updated_at.to_time.to_i
end
