json.array!(@conditions) do |condition|
  json.extract! condition, :title, :description
  json.url condition_url(condition, format: :json)
end
