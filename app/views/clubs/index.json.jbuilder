json.array!(@clubs) do |club|
  json.extract! club, :id, :title, :description, :location, :privacy_id, :club_type_id
  json.logo club_logo_url(club, :small)
  json.url club_url(club, format: :json)
  json.members club.list_members
  json.rides_count club.rides_count
  json.members_count club.list_members.count
end
