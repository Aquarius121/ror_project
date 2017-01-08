class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |t|
      t.string :title
      t.string :logo
      t.text :description
      t.string :location
      t.references :privacy, index: true
      t.references :ClubType, index: true

      t.timestamps
    end
  end
end
