class AddGalleryIdToAttachment < ActiveRecord::Migration
  def change
    add_reference :attachments, :gallery, index: true
  end
end
