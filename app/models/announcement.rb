# == Schema Information
#
# Table name: announcements
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  body       :text
#  club_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Announcement < ActiveRecord::Base
  include Extended
  belongs_to :club

  validates_presence_of :club

  def reactify user
    to_json only: :title, methods: %i[ url avatar_url date ]
  end

  def url
    route :v2_announcement_path, self
  end

  def avatar_url
    '/images/announcement.png'
  end

  def date
    created_at.to_s :date_short
  end
end
