class AnnouncementsController < ApplicationController
  before_action :set_announcement, only: [:show, :edit, :update, :destroy]

  def index
    @announcements = Announcement.all
  end

  def show_for_club
    if Member.is_in_club_approved?(params[:club_id], current_user.id)
      @announcements = Announcement.where(:club_id => params[:club_id]).to_a
    else
      @announcements = false
    end
  end
  
  def show
  end

  def new
    club = Club.find(params[:club_id])
    if club.is_owner?(current_user)
      @announcement = Announcement.new(:club_id => params[:club_id])
    else
      @announcement = false
    end
    render :template => "announcements/new", :layout => false
  end

  def edit
  end

  def create
    club = Club.find(announcement_params[:club_id])
    if club.is_owner?(current_user)
      @announcement = Announcement.new(announcement_params)
      club.list_members.each do |user|
        body = HTMLEntities.new.encode(@announcement.body)
        NotificationMailer.delay.new_announcement(user.id, @announcement.title, body, club.title)
      end
      respond_to do |format|
        if @announcement.save
          format.html { redirect_to @announcement, notice: 'Announcement was successfully created.' }
          format.json { render action: 'show', status: :created, location: @announcement }
        else
          format.html { render action: 'new' }
          format.json { render json: @announcement.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to authenticated_root_path }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
      
  end

  def update
    respond_to do |format|
      if @announcement.update(announcement_params)
        format.html { redirect_to @announcement, notice: 'Announcement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @announcement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @announcement.destroy
    respond_to do |format|
      format.html { redirect_to announcements_url }
      format.json { head :no_content }
    end
  end

  private
  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def announcement_params
    params.require(:announcement).permit(:title, :body, :club_id)
  end
end
