class V2::AnnouncementsController < V2Controller
  before_action :set_announcement

  def show
    redirect_to announcements_v2_club_path @announcement.club, anchor: @announcement.id
  end

  private
  def set_announcement
    @announcement = Announcement.find params[:id]
  end
end
