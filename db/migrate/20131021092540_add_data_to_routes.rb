class AddDataToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :data, :text
  end
end
