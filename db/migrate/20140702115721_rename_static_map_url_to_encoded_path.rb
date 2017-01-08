class RenameStaticMapUrlToEncodedPath < ActiveRecord::Migration
  def change
    rename_column(:routes, :static_map_url, :encoded_path)
  end
end
