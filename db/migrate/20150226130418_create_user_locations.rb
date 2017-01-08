class CreateUserLocations < ActiveRecord::Migration
  def change
    create_table :user_locations do |t|
      t.belongs_to :user, index: true
      t.decimal :latitude, precision: 9, scale: 6, null: false
      t.decimal :longitude, precision: 9, scale: 6, null: false
      t.timestamps null: false
    end
    add_foreign_key :user_locations, :users
    add_index :user_locations, :updated_at
  end
end
