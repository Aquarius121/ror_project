class RenameClubType < ActiveRecord::Migration
  def change
    rename_column :clubs, :ClubType_id, :club_type_id
  end
end
