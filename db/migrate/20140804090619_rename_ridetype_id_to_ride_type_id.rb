class RenameRidetypeIdToRideTypeId < ActiveRecord::Migration
  def change
    rename_column :routes, :ridetype_id, :ride_type_id
  end
end
