# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  firstname              :string(255)
#  lastname               :string(255)
#  zip                    :string(255)
#  motorcycle_club        :string(255)
#  fb_id                  :integer
#  fb_token               :string
#  location               :string(255)
#  gender                 :string(255)
#  age                    :string(255)
#  about_me               :text
#  riding_preference      :string(255)
#  subscribed             :boolean
#  avatar_id              :integer
#  authentication_token   :string(255)
#  subscription_id        :integer
#  fb_friends_ids         :integer          default("{}"), is an Array
#  fb_fetched_at          :datetime
#  latitude               :decimal(9, 6)
#  longitude              :decimal(9, 6)
#  role_id                :integer
#  time_zone              :string(255)
#  device_tokens          :text             default("{}"), is an Array
#  fb_session_expired     :boolean          default("false")
#  app_settings           :hstore
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
