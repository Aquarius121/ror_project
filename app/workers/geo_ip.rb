#require 'geoip2'

class GeoIp
  include Sidekiq::Worker

  #call this method every 2-3 days to ensure that user's location is updated
  def perform(user_id, ip_address)
    db = MaxMindDB.new('./GeoLite2-City.mmdb')
    ret = db.lookup(ip_address)
    if ret.found?
      user = User.find user_id
      if user
        user.latitude = ret.location.latitude
        user.longitude = ret.location.longitude
        user.save!
      end
    end
    #city = GeoIP2::locate ip_address
    #if city && city['postal_code']
    #  user = User.find user_id
    #  if user
    #     user.latitude = city['latitude']
    #     user.longitude = city['longitude']
    #    user.save!
    #  end
    #end
  end
end