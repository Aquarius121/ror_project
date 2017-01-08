json.array!(@activities) do |activity|
  json.extract! activity, :id, :user_id, :follower_id, :activity_date, :activity_text
  json.url activity_url(activity, format: :json)
end
