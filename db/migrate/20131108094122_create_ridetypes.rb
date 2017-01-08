class CreateRidetypes < ActiveRecord::Migration
  def change
    create_table :ridetypes do |t|
      t.string :title

      t.timestamps
    end
  end
end
