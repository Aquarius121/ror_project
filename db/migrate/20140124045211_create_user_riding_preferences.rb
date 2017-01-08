class CreateUserRidingPreferences < ActiveRecord::Migration
  def change
    create_table :user_riding_preferences do |t|
      t.integer :user_id
      t.integer :preference_id

      t.timestamps
    end
  end
end
