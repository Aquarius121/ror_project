class AddFieldsToClub < ActiveRecord::Migration
  def change
    add_column :clubs, :website, :string
    add_column :clubs, :url, :string
  end
end
