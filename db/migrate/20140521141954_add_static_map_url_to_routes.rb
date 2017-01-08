class AddStaticMapUrlToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :static_map_url, :string, :limit => 4096
  end
end
