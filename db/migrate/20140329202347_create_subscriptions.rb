class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :transaction_id
      t.integer :premium_plan_id
      t.string :duration
      t.timestamps
    end
  end
end
