json.array!(@attachments) do |attachment|
  json.extract! attachment, :id, :file
  json.url attachment_url(attachment, format: :json)
end
