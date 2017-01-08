# == Schema Information
#
# Table name: premium_plans
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  price       :float
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  period      :integer
#  label       :string(255)
#  archived    :boolean          default("false"), not null
#  role_id     :integer
#

class PremiumPlan < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  has_paper_trail

  has_many :subscriptions
  has_one :coupon
  belongs_to_active_hash :role

  validates :role_id, presence: true

  scope :active, ->{ where(archived: false) }
  scope :for_combined_form, ->{ active }
  scope :for_upgrade_form, ->{ active }
end
