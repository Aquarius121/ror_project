class AddFieldLableInPremiumPLan < ActiveRecord::Migration
  def change
    add_column :premium_plans, :label, :string
  end
end
