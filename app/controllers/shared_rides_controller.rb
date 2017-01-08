class SharedRidesController < ApplicationController
  before_action :set_shared_ride, only: [:show, :edit, :update, :destroy]

  def index
    @shared_rides = SharedRide.all
  end

  def show
  end

  def new
    @route = Route.find(params[:id])
    @shared_ride = SharedRide.new
    render :template => "shared_rides/share", :layout => false
  end

  def edit
  end

  def see_rides
    @rides = Route.not_deleted.joins(:shared_ride).where(shared_rides: {user_id: current_user.id, new: true}).to_a
    SharedRide.for_user(current_user.id).update_all(:new => false)
    render 'routes/search.json'
  end

  def newsharecount
    @count = SharedRide.for_user(current_user.id).count
  end

  #TODO Rewrite using of list_friends
  def shareautocomplete
    @friends = User.where([:firstname, :lastname].matches("%#{params[:name]}%")).where(:id => Friendship.list_friends(current_user))
  end

  def sharegetfriends
    @route = Route.find(params[:id])
    @shared_friends = User.joins(:shared_ride).where(shared_rides: {:route_id => @route.id})
  end

  def share_via_email
    route = Route.find(params[:shared_ride][:route_id])
    email = params[:shared_ride][:email]
    if route.user_id == current_user.id
      NotificationMailer.delay.share_route_via_email(current_user.id, email, route.id)
    end
    @shared_rides = [SharedRide.last]
    render text: '{"status":"OK"}', status: :created
  end

  def create
    @route = Route.find(params['shared_ride'][:route_id])
    @shared_friends = SharedRide.where({:route_id => @route.id})
    friendlist = params['shared_ride']['friend'].split(',').uniq
    @shared_friends.each do |share|
      if SharedRide.isNotShareForFriend(share.user_id, friendlist)
        share.destroy
      end
    end
    if @route.user_id == current_user.id && params['shared_ride']['friend']
      friendlist.each do |fid|
        if !SharedRide.isShareForFriend(fid.to_i, @shared_friends)
          @shared_ride = SharedRide.new(route_id: @route.id, user_id: fid, new: true)
          if !@shared_ride.save
            respond_to do |format|
              format.html { render action: 'new' }
              format.json { render json: @route.errors, status: :unprocessable_entity }
            end
          end
          user = User.find(fid)
          message = HTMLEntities.new.encode(params['shared_ride']['message'])
          NotificationMailer.delay.share_route(user.id, current_user.id, @route.id, message)
          args = {:full_name => current_user.full_name, :route => @route}
          Activity.add_activity('activities/template/share_route', args, current_user.id, user.id)
        end
      end
      respond_to do |format|
        @shared_rides = SharedRide.where({:route_id => @route.id})
        format.html { redirect_to @route, notice: 'Shared ride was successfully created.' }
        format.json { render action: 'doshare', status: :created }
      end
    end
  end

  def update
    respond_to do |format|
      if @shared_ride.update(shared_ride_params)
        format.html { redirect_to @shared_ride, notice: 'Shared ride was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shared_ride.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @shared_ride.destroy
    respond_to do |format|
      format.html { redirect_to shared_rides_url }
      format.json { head :no_content }
    end
  end

  private
  def set_shared_ride
    @shared_ride = SharedRide.find(params[:id])
  end

  def shared_ride_params
    params.require(:shared_ride).permit(:route_id, :user_id)
  end
end
