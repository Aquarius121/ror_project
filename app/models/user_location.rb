# == Schema Information
#
# Table name: user_locations
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  latitude   :decimal(9, 6)    not null
#  longitude  :decimal(9, 6)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserLocation < ActiveRecord::Base
  belongs_to :user

  scope :close_to, ->(latitude, longitude, distance_in_meters = 25000) {
    where(%{
      ST_DWithin(
        ST_GeographyFromText(
          'SRID=4326;POINT(' || user_locations.longitude || ' ' || user_locations.latitude || ')'
        ),
        ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
        %d
      )
    } % [longitude, latitude, distance_in_meters])
  }

  scope :fresh, -> { where(['updated_at > ?', 30.minutes.ago]) }

  def self.for_user(user)
    UserLocation.find_by(user: user)
  end

  def self.for_users(users)
    UserLocation.where(user_id: users).includes(:user)
  end

  def as_json(options = nil)
    super(
        {
            only: [:latitude, :longitude],
            include: {user: {only: [:id, :firstname, :lastname]}}
        }.merge(options || {})
    )
  end

end
