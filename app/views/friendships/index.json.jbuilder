json.array!(@friendships) do |friendship|
  json.extract! friendship, :follower_id, :user_id, :active, :date
  json.url friendship_url(friendship, format: :json)
end
