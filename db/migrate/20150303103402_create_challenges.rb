class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.string :name
      t.string :description
      t.datetime :start_at
      t.datetime :end_at
      t.float :target
      t.boolean :featured
      t.string :prize
      t.string :sponsor

      t.timestamps null: false
    end
  end
end
