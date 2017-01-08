class AddReadonlyToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :is_readonly, :boolean, default: false
  end
end
