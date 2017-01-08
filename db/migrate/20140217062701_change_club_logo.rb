class ChangeClubLogo < ActiveRecord::Migration
   change_table :clubs do |t|
      drop_attached_file :clubs, :logo
      t.references :logo
    end
end
