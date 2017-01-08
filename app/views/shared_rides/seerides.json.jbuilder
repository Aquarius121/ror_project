json.array!(@rides) do |route|
  json.extract! route, :id, :title, :description
  json.ridedate route.ridedate.to_formatted_s(:long_ordinal)
  json.type Route.type_of_my_ride(route, current_user)
end
