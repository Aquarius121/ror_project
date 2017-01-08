json.array!(@premium_plans) do |premium_plan|
  json.extract! premium_plan, :id
  json.url premium_plan_url(premium_plan, format: :json)
end
