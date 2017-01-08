class ReverseGallery < ActiveRecord::Migration
  def change
    change_table(:galleries) do |t|
      t.belongs_to :route, index: true
    end
    execute("update galleries set route_id = (select gallery_id from routes where routes.gallery_id = galleries.id limit 1)")
    remove_column(:routes, :gallery_id, :integer)
  end
end
