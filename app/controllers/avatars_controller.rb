class AvatarsController < ApplicationController

  def create
    if current_user
      @status = current_user.update_avatar params[:file]
      @url = Attachment.find(current_user.avatar_id).file.url(:thumb)
      @avatar_id = current_user.avatar_id
    end
  end

end
