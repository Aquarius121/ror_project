class CouponsController < ApplicationController
  before_action :set_coupon, only: [:show, :edit, :update, :destroy]
  authorize_resource :class => false
  layout 'manage'


  def index
    @coupons = Coupon.all
  end

  def show
    @plan  = PremiumPlan.find(@coupon.premium_plan_id)
  end

  def new
    @coupon = Coupon.new
  end

  def edit
  end

  def create
    @coupon = Coupon.new(coupon_params)
    @coupon.code = Coupon.generate_code
    @coupon.premium_plan = PremiumPlan.find(get_premium_plan)
    respond_to do |format|
      if @coupon.save
        format.html { redirect_to @coupon, notice: 'Coupon was successfully created.' }
        format.json { render action: 'show', status: :created, location: @coupon }
      else
        format.html { render action: 'new' }
        format.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @coupon.update(coupon_params)
        format.html { redirect_to @coupon, notice: 'Coupon was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @coupon.destroy
    respond_to do |format|
      format.html { redirect_to coupons_url }
      format.json { head :no_content }
    end
  end

  private
    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(:name,:discount)
    end

    def get_premium_plan
      params[:coupon][:premium_plan_id].to_i
    end
end
