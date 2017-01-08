class V2::ClubsController < V2Controller
  before_action :set_club, except: [:index, :new, :create]
  before_action :set_club_aggregator, only: [:show, :announcements]

  # TODO group list
  def index
    @filter = ClubFilter.new filter_params.to_h
    @clubs  = @filter.empty? ? Club.all : Club.advanced_search(@filter)
  end

  def new
    @club = Club.new
  end

  def show
    items = @aggregator.stats
    @stats = {
      heading:   'club stats',
      component: 'StatItem',
      items:     items,
      per_row:   items.count
    }

    @info = {
      heading: 'club info',
      tabs: {
        'Leaderboard' => {
          component: 'Leaderboard',
          items:     @aggregator.leaderboards
        },
        'Members'     => {
          component: 'UserListItem',
          items:     @aggregator.members
        },
        'Description' => {
          content:   @club.description
        }
      }
    }

    @upcoming_rides = {
      expandable: false,
      component:  'SidebarRideListItem',
      heading:    'Upcoming rides',
      layout:     'list',
      items:      @aggregator.upcoming_rides
    }

    @announcements  = {
      expandable: false,
      component:  'SidebarAnnounceListItem',
      heading:    'Announcements',
      layout:     'list',
      items:      @aggregator.announcements
    }

    @modal_params = {
      title: 'Invite friends',
      backdrop: true
    }

    @friends = {
      url: invite_v2_club_path,
      friends: current_user.aggregator(true, current_user).friends,
      csrf_param: request_forgery_protection_token,
      csrf_token: form_authenticity_token
    }
  end

  # TODO join group
  def join
    redirect_to :back, notice: "Already a member of #{ @club.title }" and return if Member.is_in_club?(@club.id, current_user.id)
    member = current_user.join @club
    if member.active
      redirect_to :back, notice: "Joined #{ @club.title }"
    else
      redirect_to :back, notice: "Request to join #{ @club.title } sent, awaiting approval"
    end
  end

  # TODO leave from group
  def leave
    if current_user.leave @club
      redirect_to :back, notice: "Left #{ @club.title }"
    else
      redirect_to :back, alert: 'Something went wrong'
    end
  end

  # TODO invite
  def invite
    invited = invite_params[:user_ids].count
    if @club.invite invite_params
      redirect_to :back, notice: "Invited a #{ [invited, 'friend'.pluralize(invited)].join ' ' }"
    else
      redirect_to :back, alert: 'Something went wrong'
    end
  end

  def update
    if @club.update club_params
      redirect_to v2_club_path(@club), notice: 'Club updated'
    else
      render :edit
    end
  end

  def create
    @club = Club.new club_params

    if @club.save
      redirect_to v2_club_path(@club), notice: 'Club created'
    else
      render :edit
    end
  end

  def announcements
    @announcements = @aggregator.announcements
  end

  def announcement
    redirect_to announcements_v2_club_path
  end

  private
  def invite_params
    params.require(:club).permit user_ids: []
  end

  def club_params
    params.require(:club).permit!
  end

  def filter_params
    params.require(:filter).permit! if params[:filter].present?
  end

  def set_club
    @club = Club.find params[:id]
  end

  def set_club_aggregator
    @aggregator = @club.aggregator true, current_user
  end
end
