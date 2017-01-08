class ChangeZipFromIntToString < ActiveRecord::Migration
  def change
    change_column :users, :zip, :string
  end
end
