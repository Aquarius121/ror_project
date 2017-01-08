require 'bg_view_helper'
module ApplicationHelper
  def avatar_url(user, size = :thumb)
    user.start_avatar_update unless user.avatar_id?
    user.avatar_id? ? Attachment.find(user.avatar_id).file.url(size) : user.avatar_source_url
  end

  def current_user_avatar
    @current_user_avatar ||= avatar_url(current_user, :thumb)
  end
  
  def logged_class
    current_user ? "logged-in" : "anonymous"
  end
  
  def in_array(val = '', arr = {})
    arr.each { |param| return true if (val == param) }
    false
  end
  
  def body_bg_class
    BgViewHelper.body_bg_class(controller)
  end
  
  def randomized_background_image
    BgViewHelper.randomized_background_image
  end

end
