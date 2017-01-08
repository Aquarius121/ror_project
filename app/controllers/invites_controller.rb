class InvitesController < ApplicationController
  before_action :set_invite, only: [:show, :edit, :update, :destroy]

  def index
    @invites = Invite.all
    @approved = true
  end

  def notapproved
    @invites = Invite.where(:code => nil)
    @approved = false
    render 'index'
  end

  def approve
    @invite = Invite.find(params[:id])
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    string = (0...9).map { o[rand(o.length)] }.join
    @invite.code = string
    respond_to do |format|
      if @invite.valid?
        @invite.save
        url_code = Digest::MD5.hexdigest(@invite.id.to_s)
        NotificationMailer.delay.invite(@invite.email, @invite.full_name, @invite.code, url_code)
        format.html { redirect_to notapproved_invites_path, notice: 'Invite was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to notapproved_invites_path, notice: 'Oops' }
        format.json { render json: @invite.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def new
    @invite = Invite.new
  end

  def edit
  end

  def create
    @invite = Invite.new(invite_params)

    respond_to do |format|
      if @invite.save
        format.html { redirect_to @invite, notice: 'Invite was successfully created.' }
        format.json { render action: 'show', status: :created, location: @invite }
      else
        format.html { render action: 'new' }
        format.json { render json: @invite.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @invite.update(invite_params)
        format.html { redirect_to @invite, notice: 'Invite was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @invite.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @invite.destroy
    respond_to do |format|
      format.html { redirect_to invites_url }
      format.json { head :no_content }
    end
  end

  private
    def set_invite
      @invite = Invite.find(params[:id])
    end

    def invite_params
      params.require(:invite).permit(:firstname, :lastname, :email, :code)
    end
end
