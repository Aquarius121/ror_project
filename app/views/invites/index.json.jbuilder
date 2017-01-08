json.array!(@invites) do |invite|
  json.extract! invite, :id, :firstname, :lastname, :email, :code
  json.url invite_url(invite, format: :json)
end
