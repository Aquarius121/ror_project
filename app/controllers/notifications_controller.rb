class NotificationsController < ApplicationController
  before_action :set_route

  def create
    if current_user.role?(:free)
      render text: 'Only premium and plus users can use offline maps.', status: :forbidden
      return
    end
    if current_user.device_tokens.length == 0
      render text: 'Please, sign in with the app (currently iOS only) to enable offline maps.', status: :unprocessable_entity
      return
    end
    # Open the RidingSocial app to download the offline map - 54 chars
    NotifierWorker.perform_async(current_user.id, "Open the RidingSocial app to download the offline map '#{@route.title.truncate(80)}'", ride_id: @route.id)
    render json: {status: 'success'}, status: :ok
  end

  private

  def set_route
    @route = Route.find(params[:route_id])
  end
end