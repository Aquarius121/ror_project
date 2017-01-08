class AddNewFieldToSharedRides < ActiveRecord::Migration
  def change
    add_column :shared_rides, :new, :boolean
  end
end
