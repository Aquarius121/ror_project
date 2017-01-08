class CreateAppSettings < ActiveRecord::Migration
  # def change
  #   # create_table :app_settings do |t|
  #   #   t.boolean :location_sharing, default: false, null: false
  #   #   t.boolean :notifications, default: false, null: false
  #   #   t.string :units, default: 'imperial', null: false
  #   #   t.references :user
  #   #
  #   #   t.timestamps null: false
  #   # end
  #
  #   add_column :users, :app_settings, :hstore
  # end

  def up
    enable_extension :hstore
    add_column :users, :app_settings, :hstore
  end

  def down
    disable_extension :hstore
    remove_column :users, :app_settings
  end
end
