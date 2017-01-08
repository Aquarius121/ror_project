# == Schema Information
#
# Table name: group_rides
#
#  id         :integer          not null, primary key
#  route_id   :integer
#  club_id    :integer
#  planned_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GroupRide < ActiveRecord::Base
  belongs_to :group, class_name: 'Club'
  belongs_to :route

  delegate :title, to: :route

  def reactify user=nil
    @reactifier = user
    to_json only:[:id], methods: [:title, :date]
  end

  def date
    self[:planned_at].try :to_formatted_s, :date_short
  end
end
