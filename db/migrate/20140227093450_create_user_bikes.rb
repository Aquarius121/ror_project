class CreateUserBikes < ActiveRecord::Migration
  def change
    create_table :user_bikes do |t|
      t.references :user, index: true
      t.string :model
      t.references :type

      t.timestamps
    end
  end
end
