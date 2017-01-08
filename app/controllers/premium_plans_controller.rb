class PremiumPlansController < ApplicationController
  before_action :set_premium_plan, only: [:show, :edit, :update, :destroy]
  authorize_resource :class => false
  layout 'manage'

  def index
    @premium_plans = PremiumPlan.active
  end

  def show
  end

  def new
    @premium_plan = PremiumPlan.new
  end

  def edit
  end

  def create
    @premium_plan = PremiumPlan.new(premium_plan_params)

    respond_to do |format|
      if @premium_plan.save
        format.html { redirect_to @premium_plan, notice: 'Premium plan was successfully created.' }
        format.json { render action: 'show', status: :created, location: @premium_plan }
      else
        format.html { render action: 'new' }
        format.json { render json: @premium_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @premium_plan.update(premium_plan_params)
        format.html { redirect_to @premium_plan, notice: 'Premium plan was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @premium_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @premium_plan.destroy
    respond_to do |format|
      format.html { redirect_to premium_plans_url }
      format.json { head :no_content }
    end
  end

  private
    def set_premium_plan
      @premium_plan = PremiumPlan.find(params[:id])
    end

    def premium_plan_params
      params.require(:premium_plan).permit(:name,:price,:description,:label,:period)
    end
end
