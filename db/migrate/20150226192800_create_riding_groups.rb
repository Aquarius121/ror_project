class CreateRidingGroups < ActiveRecord::Migration
  def change
    create_table :riding_groups do |t|
      t.string :title
      t.belongs_to :leader
      t.integer :riders, array: true, default: []

      t.timestamps null: false
    end
  end
end
