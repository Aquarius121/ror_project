class AddFieldsInPayment < ActiveRecord::Migration
  def change
    add_column :premium_plans, :period, :integer
  end
end
