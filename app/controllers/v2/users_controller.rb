class V2::UsersController < V2Controller
  before_action :set_user, except: :index
  before_action :set_is_friend, except: :index

  def index
    @filter = UserFilter.new filter_params.to_h
    @users  = @filter.empty? ? User.all : current_user.friends_search(@filter)
  end

  def show
    aggregator = @user.aggregator true, current_user
    stats = aggregator.stats

    @stats = {
      heading:   @is_friend ? 'Friend stats' : 'User stats',
      component: 'StatItem',
      items:     stats,
      per_row:   stats.count
    }

    @info = {
      heading: @is_friend ? 'Friend info' : 'User Info',
      tabs:    {
        'Rides' => {
          component: 'RideListItem',
          items:     aggregator.rides
        },
        'Groups' => {
          component: 'GroupListItem',
          items:     aggregator.groups
        },
        'Challenges' => {
          component: 'ChallengeListItem',
          items:     aggregator.challenges
        }
      }
    }

    current_user_aggregator = current_user.aggregator true, current_user

    @suggested_friends = {
      expandable: false,
      component:  'UserListItemWithPopup',
      heading:    'Suggested friends',
      sidebar:    true,
      layout:     'list',
      items:      current_user_aggregator.suggested_friends
    }
  end

  # TODO befriend
  def befriend
    friendship_status = current_user.make_friends_with @user
    case friendship_status
      when :already_friends
        redirect_to :back, notice: "You're already friends with #{ @user.full_name }"
      when :request_approved
        redirect_to :back, notice: "You have approved friend request from #{ @user.full_name }"
      when :request_sent
        redirect_to :back, notice: "Friend request sent to #{ @user.full_name }"
      else
        redirect_to :back, alert: 'Something happened...'
    end
  end

  # TODO unfriend
  def unfriend
    if current_user.unfriend @user
      redirect_to :back, notice: "You're no longer friends with #{ @user.full_name }"
    else
      redirect_to :back, alert: 'Something happened...'
    end
  end

  private
  def set_is_friend
    @is_friend = current_user.is_friends_with? @user.id
  end

  # TODO sanitize params
  def filter_params
    params.require(:filter).permit! if params[:filter].present?
  end

  def set_user
    @user = User.find params[:id]
  end
end
