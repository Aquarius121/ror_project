class AddDistanceAndTimeToRoutes < ActiveRecord::Migration
  def change
    add_column :routes , :ride_distance, :integer
    add_column :routes , :ride_time, :integer
  end
end
