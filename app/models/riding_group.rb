# == Schema Information
#
# Table name: riding_groups
#
#  id         :integer          not null, primary key
#  title      :string
#  leader_id  :integer
#  riders     :integer          default("{}"), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RidingGroup < ActiveRecord::Base
  belongs_to :leader, class_name: 'User'
  validates :leader_id, uniqueness: {message: 'You already have a group: the group with your leader id exists. To create a new group delete existing one.'}

  scope :with_rider, ->(user_id) { where(['? = ANY(riders)', user_id]) }

  def as_json(options = nil)
    super(
        {
            only: [:id, :title, :leader_id],
            methods: [:rider_users]
        }.merge(options || {})
    )
  end

  def rider_users
    UserLocation.for_users(riders).map do |user_location|
      user_location.as_json(include: {user: {methods: [:avatar_url], only: [:id, :firstname, :lastname]}})
    end
  end

  def add_rider(rider_id)
    RidingGroup.transaction do
      previous_groups = RidingGroup.with_rider(rider_id).to_a
      previous_groups.each do |group|
        group.remove_rider(rider_id)
      end
      update!(riders: riders + [rider_id])
    end
  end

  def remove_rider(rider_id)
    if self.riders.include?(rider_id)
      update!(riders: riders - [rider_id])
    else
      false
    end
  end

  # there can be only one group for user (he will be either leader or rider)
  def self.for_user(user)
    @group_with_leader_role = RidingGroup.find_by(leader_id: user.id)
    if !@group_with_leader_role
      @groups_with_rider_role = RidingGroup.with_rider(user.id).to_a
      logger.warn "several groups for user #{user.id}: #{@groups_with_rider_role.map(&:id)}" if @groups_with_rider_role.size > 1
    end
    @group_with_leader_role || @groups_with_rider_role.first
  end
end
