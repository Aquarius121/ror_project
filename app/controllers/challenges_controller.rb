class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show, :edit, :update,
                                       :destroy, :join, :leaderboard, :leave]
  authorize_resource :class => false
  layout 'manage'

  def index
    if params[:id]
      my_challenges = !current_user.role?(:admin) || params[:id] == 'me'
      @challenges = my_challenges ? current_user.challenges : User.find(params[:id]).challenges
    else
      @challenges = Challenge.all
    end
  end

  def show
  end

  def new
    @challenge = Challenge.new
  end

  def edit
  end

  def join
    if @challenge.users.include? current_user
      render json: {errors:'You have already joined this challenge.'}, status: :unprocessable_entity
    else
      @rank = Rank.new(challenge:@challenge, user: current_user, total_data: 0)
      if @rank.save
        render json: @rank, status: :created
      else
        render json: @rank.errors, status: :unprocessable_entity
      end
    end
  end

  def leave
    unless @challenge.users.include? current_user
      render json: {errors:'You have\'t joined this challenge yet.'}, status: :unprocessable_entity
    else
      @rank = Rank.find_by(challenge:@challenge, user: current_user)
      @rank.destroy
      head :no_content
    end
  end

  def leaderboard
    leaderboard = @challenge.ranks.order(:rank).map do |r|
      {rank: r.rank, full_name: r.user.full_name, total_data: r.total_data }
    end
    render json: leaderboard
  end

  def create
    @challenge = Challenge.new(challenge_params)
    respond_to do |format|
      if @challenge.save
        format.html { redirect_to @challenge, notice: 'Challenge was successfully created.' }
        format.json { render action: 'show', status: :created, location: @challenge }
      else
        format.html { render action: 'new' }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @challenge.update(challenge_params)
        format.html { redirect_to @challenge, notice: 'Challenge was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to challenges_url }
      format.json { head :no_content }
    end
  end

  private
  def set_challenge
    @challenge = Challenge.find(params[:id])
  end

  def challenge_params
    params.require(:challenge).permit(:name, :description, :start_at, :end_at,
                                      :target, :featured, :prize, :sponsor)
  end

end
