# == Schema Information
#
# Table name: subscriptions
#
#  id              :integer          not null, primary key
#  transaction_id  :integer
#  premium_plan_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  card_expires_at :date
#  email_sent      :boolean
#  coupon_id       :integer
#  canceled_at     :datetime
#

class Subscription < ActiveRecord::Base
  validates :transaction_id, :presence => true
  belongs_to :premium_plan
  belongs_to :coupon
  has_one :user

  delegate :price, :to => :premium_plan, :prefix => false

  has_paper_trail

  def type
    return 'premium_plan.period is nil' unless premium_plan
    return 'monthly' if premium_plan.period == 1
    return 'quarterly' if premium_plan.period == 3
    return 'semiannual' if premium_plan.period == 6
    return 'annual' if premium_plan.period == 12
    'please define type in Subscription.rb'
  end

end
