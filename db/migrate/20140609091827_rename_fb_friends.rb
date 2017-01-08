class RenameFbFriends < ActiveRecord::Migration
  def change
    rename_column :users, :fb_friends, :fb_friends_ids
  end
end
