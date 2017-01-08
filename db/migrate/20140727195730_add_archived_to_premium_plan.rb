class AddArchivedToPremiumPlan < ActiveRecord::Migration
  def change
    add_column :premium_plans, :archived, :boolean, null: false, default: false
  end
end
