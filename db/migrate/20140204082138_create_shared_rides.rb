class CreateSharedRides < ActiveRecord::Migration
  def change
    create_table :shared_rides do |t|
      t.integer :route_id
      t.integer :user_id

      t.timestamps
    end
  end
end
