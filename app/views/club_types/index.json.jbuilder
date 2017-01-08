json.array!(@club_types) do |club_type|
  json.extract! club_type, :title
  json.url club_type_url(club_type, format: :json)
end
