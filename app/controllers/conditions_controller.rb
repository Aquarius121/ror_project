class ConditionsController < ApplicationController
  before_action :set_condition, only: [:show, :edit, :update, :destroy]

  def index
    @conditions = Condition.all
  end

  def show
  end

  def new
    @condition = Condition.new
  end

  def edit
  end

  def create
    @condition = Condition.new(condition_params)

    respond_to do |format|
      if @condition.save
        format.html { redirect_to @condition, notice: 'Condition was successfully created.' }
        format.json { render action: 'show', status: :created, location: @condition }
      else
        format.html { render action: 'new' }
        format.json { render json: @condition.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @condition.update(condition_params)
        format.html { redirect_to @condition, notice: 'Condition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @condition.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @condition.destroy
    respond_to do |format|
      format.html { redirect_to conditions_url }
      format.json { head :no_content }
    end
  end

  private
    def set_condition
      @condition = Condition.find(params[:id])
    end

    def condition_params
      params.require(:condition).permit(:title, :description)
    end
end
