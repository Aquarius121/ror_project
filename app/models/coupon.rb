# == Schema Information
#
# Table name: coupons
#
#  id              :integer          not null, primary key
#  premium_plan_id :integer
#  code            :string(255)
#  discount        :integer
#  created_at      :datetime
#  updated_at      :datetime
#  name            :string(255)
#

class Coupon < ActiveRecord::Base
  belongs_to :premium_plan

  def self.generate_code size = 10
    chars = ('a'..'z').to_a + ('A'..'Z').to_a
    (0...size).collect { chars[Kernel.rand(chars.length)] }.join
  end

end
