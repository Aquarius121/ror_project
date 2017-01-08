class CreateRideTypes < ActiveRecord::Migration
  def change
    create_table :ride_types do |t|
      t.string :title

      t.timestamps
    end
  end
end
