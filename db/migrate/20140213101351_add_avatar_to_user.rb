class AddAvatarToUser < ActiveRecord::Migration
  def change
    add_reference :users, :avatar, index: true
  end
end
