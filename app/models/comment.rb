# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  related_id :integer
#  user_id    :integer
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :route
  belongs_to :user
  
  validates :body, :presence => true
  validates :user, :presence => true

  scope :for_route, ->(route_id) {where(:related_id => route_id)}
  
  
end
