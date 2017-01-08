json.array!(@referrals) do |referral|
  json.extract! referral, :id, :user_id, :referral_id
  json.url referral_url(referral, format: :json)
end
