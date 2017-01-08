class AddFbTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fb_token, :varchar
  end
end
