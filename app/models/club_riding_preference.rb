# == Schema Information
#
# Table name: club_riding_preferences
#
#  id                   :integer          not null, primary key
#  club_id              :integer
#  riding_preference_id :integer
#  created_at           :datetime
#  updated_at           :datetime
#

class ClubRidingPreference < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to_active_hash :riding_preference
  belongs_to :club
end
