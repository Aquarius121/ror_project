class CreateRidingPreferences < ActiveRecord::Migration
  def change
    create_table :riding_preferences do |t|
      t.string   :title
      t.timestamps
    end
  end
end
