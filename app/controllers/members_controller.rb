class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  def index
    @members = Member.all
  end

  def show
  end

  def listforapprove
    @club_id = params[:club_id]
    @members = User.eager_load(:member).where(members: {:club_id => params[:club_id], :active => false}).limit(30)
    render :template => 'members/listforapprove', :layout => false
  end


  def approve
    if Club.find(params[:club_id]).is_owner?(current_user)
      approve = []
      delete = []
      params[:member].each do |id, val|
        if val == 'true'
          approve.push(id)
        else
          delete.push(id)
        end
      end
      Member.where(:club_id => params[:club_id], :user_id => approve).update_all(:active => true)
      Member.where(:club_id => params[:club_id], :user_id => delete).delete_all
      @approve_count = Member.where(:club_id => params[:club_id], :active => false).count()
    end
  end


  def new
    @member = Member.new
  end

  def edit
  end

  def create
    if Member.is_in_club?(params[:member][:club_id], current_user.id)
      return
    end
    club = Club.find_by_id(params[:member][:club_id])
    if club.privacy_id == 2
      params[:member][:active] = true
    else
      params[:member][:active] = false
    end
    params[:member][:user_id] = current_user.id
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render action: 'show', status: :created, location: @member }
      else
        format.html { render action: 'new' }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url }
      format.json { head :no_content }
    end
  end

  private
  def set_member
    @member = Member.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:club_id, :user_id, :active)
  end
end
