class CreateReferals < ActiveRecord::Migration
  def change
    create_table :referals do |t|
      t.integer :user_id
      t.integer :referal_id

      t.timestamps
    end
  end
end
