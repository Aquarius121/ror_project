# == Schema Information
#
# Table name: shared_rides
#
#  id         :integer          not null, primary key
#  route_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  new        :boolean
#

class SharedRide < ActiveRecord::Base
  belongs_to :route
  belongs_to :user

  scope :for_user, ->(user_id) {
    where({user_id: user_id, new: true})
  }
  
  def self.isShareForFriend(id, shared = Array.new)
    shared.each do |p|
      if p.user_id == id
        return true
      end
    end
    return false
  end
  
  def self.isNotShareForFriend(id, friends = Array.new)
    friends.each do |p|
      if p.to_i == id.to_i
        return false
      end
    end
    return true
  end
  
end
