# == Schema Information
#
# Table name: galleries
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  route_id   :integer
#

class Gallery < ActiveRecord::Base
  belongs_to :route
  has_many :attachments
  accepts_nested_attributes_for :attachments, allow_destroy: true
end
