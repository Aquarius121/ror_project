class RenameRideTypeIdToSurfaceId < ActiveRecord::Migration
  def change
    rename_column :routes, :ridetype_id, :surface_id
  end
end
