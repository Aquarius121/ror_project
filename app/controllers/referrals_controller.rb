class ReferralsController < ApplicationController
  before_action :set_referral, only: [:show, :edit, :update, :destroy]

  def index
    @referrals = Referral.all
  end

  def show
  end

  def new
    @referral = Referral.new
  end

  def edit
  end

  def create
    @referral = Referral.new(referral_params)

    respond_to do |format|
      if @referral.save
        format.html { redirect_to @referral, notice: 'Referral was successfully created.' }
        format.json { render action: 'show', status: :created, location: @referral }
      else
        format.html { render action: 'new' }
        format.json { render json: @referrsal.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @referral.update(referral_params)
        format.html { redirect_to @referral, notice: 'Referral was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @referral.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @referral.destroy
    respond_to do |format|
      format.html { redirect_to referrals_url }
      format.json { head :no_content }
    end
  end

  private
    def set_referral
      @referral = Referral.find(params[:id])
    end

    def referral_params
      params.require(:referral).permit(:user_id, :referral_id)
    end
end
