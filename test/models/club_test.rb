# == Schema Information
#
# Table name: clubs
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  logo         :string(255)
#  description  :text
#  location     :string(255)
#  privacy_id   :integer
#  club_type_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  owner_id     :integer
#  logo_id      :integer
#  website      :string(255)
#  url          :string(255)
#

require 'test_helper'

class ClubTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
