class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.integer :follower_id
      t.integer :user_id
      t.boolean :active
      t.datetime :date

      t.timestamps
    end
  end
end
