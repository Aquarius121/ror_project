class ReferalsToReferrals < ActiveRecord::Migration
  def change
    rename_table :referals, :referrals
  end
end
