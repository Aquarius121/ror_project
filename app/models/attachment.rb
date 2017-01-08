# == Schema Information
#
# Table name: attachments
#
#  id                :integer          not null, primary key
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  gallery_id        :integer
#

class Attachment < ActiveRecord::Base
  has_one :user, :class_name => 'User', :foreign_key => 'avatar_id'
  has_one :club
  belongs_to :gallery
  delegate :route, to: :gallery
  has_attached_file :file, :styles => {:medium => ['250x200#', 'png'], :small => ['120x120>', 'png'],
                                       :thumb => ['50x50#', 'png']},
                    :default_url => ''
  validates_attachment_content_type :file, :content_type => /\Aimage/

end
