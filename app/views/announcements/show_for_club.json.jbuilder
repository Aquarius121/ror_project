json.array!(@announcements) do |announcement|
  json.extract! announcement, :id, :title, :body
end
