class CreateAffiliates < ActiveRecord::Migration
  def change
    create_table :affiliates do |t|
      t.references :club, index: true
      t.references :user, index: true
      t.boolean :active
      t.datetime :start

      t.timestamps
    end
  end
end
