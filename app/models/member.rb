# == Schema Information
#
# Table name: members
#
#  id         :integer          not null, primary key
#  club_id    :integer
#  user_id    :integer
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Member < ActiveRecord::Base
  belongs_to :club
  belongs_to :user
  
  def self.is_in_club?(club_id, user_id)
    Member.where(club_id: club_id, user_id: user_id).any?
  end
  
  def self.is_in_club_approved?(club_id, user_id)
    Member.where(club_id: club_id, user_id: user_id, active: true).any?
  end

  def self.approve_count(club_id)
    Member.where(club_id: club_id, active: false).count
  end
  
end
