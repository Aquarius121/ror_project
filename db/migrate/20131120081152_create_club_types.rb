class CreateClubTypes < ActiveRecord::Migration
  def change
    create_table :club_types do |t|
      t.string :title

      t.timestamps
    end
  end
end
