class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :title
      t.string :difficulty
      t.float :rating
      t.string :elevation
      t.date :ridedate
      t.text :description
      t.references :privacy, index: true
      t.references :condition, index: true

      t.timestamps
    end
  end
end
