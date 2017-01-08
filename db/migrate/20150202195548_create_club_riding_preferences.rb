class CreateClubRidingPreferences < ActiveRecord::Migration
  def change
    create_table :club_riding_preferences do |t|
      t.integer :club_id
      t.integer :riding_preference_id

      t.timestamps
    end
  end
end
