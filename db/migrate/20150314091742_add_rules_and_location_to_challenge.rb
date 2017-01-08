class AddRulesAndLocationToChallenge < ActiveRecord::Migration
  def change
    add_column :challenges, :rules, :string
    add_column :challenges, :location, :string
  end
end
