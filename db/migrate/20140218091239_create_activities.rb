class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, index: true
      t.references :follower, index: true
      t.date :activity_date
      t.text :activity_text

      t.timestamps
    end
  end
end
