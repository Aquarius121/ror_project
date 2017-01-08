# == Schema Information
#
# Table name: invites
#
#  id         :integer          not null, primary key
#  firstname  :string(255)
#  lastname   :string(255)
#  email      :string(255)
#  code       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Invite < ActiveRecord::Base
  validates :email, uniqueness: {message: 'address has already applied for a code. Please stand by, we are not quite ready yet.'}, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def full_name
    "#{firstname} #{lastname}"
  end
end
