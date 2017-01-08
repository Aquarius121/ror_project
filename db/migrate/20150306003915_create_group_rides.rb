class CreateGroupRides < ActiveRecord::Migration
  def change
    create_table :group_rides do |t|
      t.belongs_to :route
      t.belongs_to :club, index: true
      t.datetime :planned_at
      t.timestamps null: false
    end
    add_index :group_rides, :route_id, unique: true
  end
end
