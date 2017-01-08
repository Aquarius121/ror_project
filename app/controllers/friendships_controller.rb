class FriendshipsController < ApplicationController
  before_action :set_friendship, only: [:show, :edit, :update, :destroy]
  authorize_resource :class => false

  def index
    @friendships = Friendship.all
  end

  def show
  end

  def myfriends
    @friends = current_user.friends
  end

  def new
    @friendship = Friendship.new
  end

  def edit
  end

  def approve
    @users = User
      .select( "users.*, friendships.id as friendship_id")
      .joins('INNER JOIN "friendships" ON "friendships"."follower_id" = "users"."id"')
      .where("friendships.user_id = ? AND active = true AND NOT EXISTS(SELECT * FROM friendships fr  WHERE fr.follower_id = friendships.user_id AND fr.user_id = friendships.follower_id)", current_user.id)
  end
  
  def approvecount
    @count = Friendship
      .where("user_id = ? AND active = true AND NOT EXISTS(SELECT * FROM friendships fr  WHERE fr.follower_id = friendships.user_id AND fr.user_id = friendships.follower_id)", current_user.id)
      .count()
  end

  def suggest
    @users = Friendship.suggest(current_user, request.remote_ip)
    render 'users/search'
  end
  
  def create
    friend = User.find(params[:friendship][:user_id])
    if current_user.is_friends_with?(friend.id)
      respond_to do |format|
        format.html { redirect_to friendships_url }
        format.json { head :no_content }
      end
    else
      params[:friendship][:follower_id] = current_user.id
      params[:friendship][:active] = true
      params[:friendship][:date] = Time.current
      @friendship = Friendship.new(friendship_params)
      if Friendship.is_friend_request?(current_user, friend)
        NotificationMailer.delay.friendship_request_approve_email(friend.id, current_user.id)
        args = {:full_name => current_user.full_name}
        Activity.add_activity('activities/template/approve_friend', args, current_user.id, friend.id)
      else
        NotificationMailer.delay.friendship_request_email(friend.id, current_user.id)
      end
      respond_to do |format|
        if @friendship.save
          format.html { redirect_to @friendship, notice: 'Friendship was successfully created.' }
          format.json { render action: 'show', status: :created, location: @friendship }
        else
          format.html { render action: 'new' }
          format.json { render json: @friendship.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    @fr = Friendship.find(params[:id])
    if @fr.follower_id == params[:friendship][:follower_id].to_i && @fr.user_id == current_user.id
      respond_to do |format|
        if @friendship.update(friendship_params)
          format.html { redirect_to @friendship, notice: 'Friendship was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @friendship.errors, status: :unprocessable_entity }
        end
      end
    else 
      respond_to do |format|
        format.html { redirect_to friendships_url }
        format.json { head :no_content }
      end
    end
  end

  def destroy
    @friendship.destroy
    respond_to do |format|
      format.html { redirect_to friendships_url }
      format.json { head :no_content }
    end
  end

  private
  def set_friendship
    @friendship = Friendship.find(params[:id])
  end

  def friendship_params
    params.require(:friendship).permit(:follower_id, :user_id, :active, :date)
  end
end
