# == Schema Information
#
# Table name: user_riding_preferences
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  preference_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class UserRidingPreference < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to_active_hash :riding_preference, foreign_key: 'preference_id'
  belongs_to :user
end
