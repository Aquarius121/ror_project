class RidingGroupsController < ApplicationController

  before_action :set_riding_group, only: [:show, :update, :destroy, :add_rider, :remove_rider]
  authorize_resource class: false

  def index
    @riding_groups = RidingGroup.all
    render json: @riding_groups
  end

  def show
    render json: @riding_group
  end

  def active
    @riding_group = RidingGroup.for_user(current_user)
    if @riding_group
      status = @riding_group.leader_id == current_user.id ? 'leader' : 'rider'
      render json: @riding_group.as_json.merge(status: status)
    else
      render json: {error: 'No active groups.'}
    end
  end

  def create
    @riding_group = RidingGroup.new(riding_group_params)
    @riding_group.leader = current_user

    if @riding_group.save
      render json: @riding_group, status: :created, location: @riding_group
    else
      render json: @riding_group.errors, status: :unprocessable_entity
    end
  end

  def update
    if @riding_group.update(riding_group_params)
      render json: @riding_group, status: :ok, location: @riding_group
    else
      render json: @riding_group.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @riding_group.destroy
    head :no_content
  end

  def add_rider
    rider_id = params[:rider_id].to_i
    riders = @riding_group.riders
    if rider_id == @riding_group.leader_id
      render json: @riding_group.as_json.merge(error: 'Cannot add leader to rider\'s list')
    elsif riders.include?(rider_id)
      render json: @riding_group.as_json.merge(error: 'Rider already in that group')
    else
      User.find(rider_id)
      @riding_group.add_rider(rider_id)
      render json: @riding_group
    end
  end

  def remove_rider
    rider_id = params[:rider_id].to_i
    if @riding_group.remove_rider(rider_id)
      render json: @riding_group
    else
      render json: @riding_group.as_json.merge(error: 'No such rider in this group!')
    end
  end

  private
  def set_riding_group
    @riding_group = RidingGroup.find(params[:id])
  end

  def riding_group_params
    params.require(:riding_group).permit(:title, riders: [])
  end
end
