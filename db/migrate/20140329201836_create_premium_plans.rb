class CreatePremiumPlans < ActiveRecord::Migration
  def change
    create_table :premium_plans do |t|
      t.string :name
      t.float :price
      t.text :description
      t.timestamps
    end
  end
end