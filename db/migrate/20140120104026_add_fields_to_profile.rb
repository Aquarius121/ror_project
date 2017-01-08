class AddFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
    add_column :users, :age, :string
    add_column :users, :about_me, :text
    add_column :users, :my_garage, :text
    add_column :users, :riding_preference, :string
  end
end
