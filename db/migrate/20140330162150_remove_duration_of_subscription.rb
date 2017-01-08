class RemoveDurationOfSubscription < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :duration
  end
end
