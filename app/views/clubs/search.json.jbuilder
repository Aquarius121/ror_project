json.array!(@clubs) do |club|
  json.extract! club, :id, :title, :description, :location, :privacy_id, :club_type_id, :club_type_name, :users_count, :routes_count
  json.url club_url(club, format: :json)
 json.logo club_logo_url(club, :small)
end
