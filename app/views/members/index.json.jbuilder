json.array!(@members) do |member|
  json.extract! member, :club_id, :user_id, :active
  json.url member_url(member, format: :json)
end
