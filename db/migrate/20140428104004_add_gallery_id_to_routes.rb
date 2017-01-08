class AddGalleryIdToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :gallery_id, :integer
  end
end
