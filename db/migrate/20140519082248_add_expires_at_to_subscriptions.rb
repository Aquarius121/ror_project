class AddExpiresAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :card_expires_at, :date
    add_column :subscriptions, :email_sent, :boolean
  end
end
