json.array!(@announcements) do |announcement|
  json.extract! announcement, :id, :title, :body, :club_id
  json.url announcement_url(announcement, format: :json)
end
