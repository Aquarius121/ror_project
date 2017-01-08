class AddFacebookFriendsToUser < ActiveRecord::Migration
  def change
    add_column :users, :fb_friends, :integer, array: true, default: []
    add_column :users, :fb_fetched_at, :datetime
  end
end
