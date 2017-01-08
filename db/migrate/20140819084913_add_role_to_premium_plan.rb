class AddRoleToPremiumPlan < ActiveRecord::Migration
  def change
    add_reference :premium_plans, :role, index: true, default: 3
  end
end
