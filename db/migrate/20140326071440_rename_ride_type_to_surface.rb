class RenameRideTypeToSurface < ActiveRecord::Migration
  def change
    rename_table :ridetypes, :surfaces
  end
end
