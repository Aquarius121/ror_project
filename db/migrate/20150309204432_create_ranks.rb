class CreateRanks < ActiveRecord::Migration
  def change
    create_table :ranks do |t|
      t.belongs_to :challenge
      t.belongs_to :user
      t.integer :rank
      t.float :total_data
      t.index [:challenge_id, :user_id]
      t.index [:user_id, :challenge_id]
      t.timestamps nulls:false
    end
  end
end
