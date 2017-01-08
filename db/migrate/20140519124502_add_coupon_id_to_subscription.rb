class AddCouponIdToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :coupon_id, :integer
  end
end
