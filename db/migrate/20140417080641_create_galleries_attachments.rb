class CreateGalleriesAttachments < ActiveRecord::Migration
  def change
    create_table :galleries_attachments do |t|
      t.references :gallery, index: true
      t.references :attachment, index: true

      t.timestamps
    end
  end
end
