# == Schema Information
#
# Table name: referrals
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  referral_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Referral < ActiveRecord::Base
  belongs_to :referral, :class_name=> 'User', :foreign_key=> 'referral_id'
  belongs_to :user, :class_name=> 'User', :foreign_key=> 'user_id'
  scope :for_user, ->(user_id) {where(:user_id => user_id)}

  validates :referral, :presence => true
  validates :user, :presence => true

  def self.referrals_count(user_id)
    Referral.for_user(user_id).count
  end
  
end
