class PopularityController < ApplicationController

  def index
    route = Route.find params[:route_id]
    render json: {route_id: route.id, likes_counter: route.get_likes.size}
  end

  def create
    route = Route.find params[:route_id]
    if current_user.voted_for? route
      render json: {error: 'Allready liked this route!'}, status: :unprocessable_entity
      return
    end

    route.liked_by current_user
    render json: {route_id: route.id, likes_counter: route.get_likes.size}
  end

  def destroy
    route = Route.find params[:route_id]
    unless current_user.voted_for? route
      render json: {error: 'No likes for this route from this user yet!'}, status: :unprocessable_entity
      return
    end
    route.unliked_by current_user
    render json: {route_id: route.id, likes_counter: route.get_likes.size}
  end

end
