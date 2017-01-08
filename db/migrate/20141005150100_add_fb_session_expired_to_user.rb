class AddFbSessionExpiredToUser < ActiveRecord::Migration
  def change
    add_column :users, :fb_session_expired, :boolean, default: false
  end
end
