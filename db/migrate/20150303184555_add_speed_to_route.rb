class AddSpeedToRoute < ActiveRecord::Migration
  def change
    add_column :routes, :average_speed, :real
    add_column :routes, :max_speed, :real
  end
end
