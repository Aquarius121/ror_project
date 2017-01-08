class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :code

      t.timestamps
    end
  end
end
