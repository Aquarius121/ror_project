class AddLocationToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :latitude, :decimal, precision: 9, scale: 6
    add_column :routes, :longitude, :decimal, precision: 9, scale: 6
  end
end
