class GroupRidesController < ApplicationController

  before_action :set_group, only: [:index, :create, :destroy]
  before_action :group_ride_params, only: [:create]

  def index
    @group_rides = GroupRide.where(club_id: @group.id)
    render json: @group_rides
  end

  def create
    @group_ride = GroupRide.new(group_ride_params)
    @group_ride.club_id = @group.id
    @group_ride.route_id =  params[:route_id]

    if @group_ride.save
      render json: {id: @group_ride.id}, status: :created
    else
      render json: @group_ride.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @group_ride = GroupRide.find_by!(club_id: @group.id, route_id: params[:route_id])
    @group_ride.destroy
    head :no_content
  end

  private
  def set_group
    @group = Club.find params[:id]
  end
  def group_ride_params
    params.require(:group_ride).permit(:planned_at)
  end
end