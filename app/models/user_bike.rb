# == Schema Information
#
# Table name: user_bikes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  model      :string(255)
#  type_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class UserBike < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to_active_hash :bike_type, foreign_key: 'type_id'
  belongs_to :user

  default_scope -> { order :model }

  validates :model, presence: true
end
