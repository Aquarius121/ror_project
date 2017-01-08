module FriendsHelper

  def list_public_routes_for_user(user)
    Route.where(user_id: user.id, privacy_id: [2, 3]).order(:created_at)
  end


  def friends_popup
    render 'template/search/popup'
  end

  def search_friends
    render 'template/search/search_friends'
  end

  def search_butler_rides
    render 'template/search/search_butler_rides'
  end

  def popup_own_butler_ride_left
    render 'template/search/butler_ride_left'
  end

  def popup_own_butler_ride_right
    render 'template/search/butler_ride_right'
  end

  def approve_friends
    render 'template/search/approve_friends'
  end
end
