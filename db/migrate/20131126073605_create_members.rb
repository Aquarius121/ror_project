class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.references :club, index: true
      t.references :user, index: true
      t.boolean :active

      t.timestamps
    end
  end
end
