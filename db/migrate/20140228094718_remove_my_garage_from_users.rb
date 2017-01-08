class RemoveMyGarageFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :my_garage, :string
  end
end
