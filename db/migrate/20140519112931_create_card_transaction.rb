class CreateCardTransaction < ActiveRecord::Migration
  def change
    create_table :card_transactions do |t|
      t.string :raw_data, :limit => 4096
      t.datetime :processed_at
    end
  end
end
