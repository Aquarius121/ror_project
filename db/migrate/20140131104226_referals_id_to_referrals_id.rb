class ReferalsIdToReferralsId < ActiveRecord::Migration
  def change
    rename_column :referrals, :referal_id, :referral_id
  end
end
