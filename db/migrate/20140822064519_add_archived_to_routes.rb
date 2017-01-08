class AddArchivedToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :archived, :boolean, default: false, null: false
  end
end
