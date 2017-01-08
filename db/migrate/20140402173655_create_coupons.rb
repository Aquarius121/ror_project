class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.integer :premium_plan_id
      t.string  :code
      t.integer  :discount
      t.timestamps
    end
  end
end
