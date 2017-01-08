if Rails.env.production?
  LogStasher.add_custom_fields do |fields|
    if current_user
      fields[:user] = {email: current_user.email, id: current_user.id}
    end
    fields[:env] = Rails.env
    fields[:time] = Time.now
  end
end
