class AddDeviceTokensToUsers < ActiveRecord::Migration
  def change
    add_column :users, :device_tokens, :text, array: true, default: []
  end
end
