desc 'Try to find user location via MaxMind Geo Ip database'
task :get_zip_code => :environment do
  db = MaxMindDB.new('./GeoLite2-City.mmdb')
  users = User.where('sign_in_count > 0')
  users.find_each do |user|
    # GeoIp.perform_async(user.id, user.current_sign_in_ip || user.last_sign_in_ip)
    ip_address = user.current_sign_in_ip || user.last_sign_in_ip
    ret = db.lookup(ip_address)
    if ret.found?
      user.latitude = ret.location.latitude
      user.longitude = ret.location.longitude
      user.save!
    end
  end
end