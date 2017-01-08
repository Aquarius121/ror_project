class AddCompletedFlagForRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :completed, :boolean, :default => false
  end
end
