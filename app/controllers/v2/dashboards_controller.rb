class V2::DashboardsController < V2Controller
  def index
    aggregator = current_user.aggregator true, current_user

    stats = aggregator.stats

    @stats = {
      heading:   'My stats',
      component: 'StatItem',
      items:     stats,
      per_row:   stats.count
    }

    @expandable_rides = {
      heading: 'rides',
      tabs:    {
        'Planned' => {
          component:  'RideListItem',
          items:      aggregator.planned_rides
        },
        'Tracked' => {
          component: 'RideListItem',
          items:     aggregator.tracked_rides
        },
        'Shared'  => {
          component: 'RideListItem',
          items:     aggregator.shared_rides
        }
      }
    }

    @expandable_news = {
      heading:   "What's new",
      component: 'AnnounceListItem',
      actions: { 'View all' => v2_feeds_path },
      items:     aggregator.announcements
    }

    @expandable_groups = {
      heading: 'groups',
      actions: { 'View all' => v2_clubs_path },
      tabs:    {
        'My groups'  => {
          component: 'GroupListItemWithPopup',
          items:     aggregator.groups
        },
        'Group Rides' => {
          component: 'RideListItem',
          items:     aggregator.group_rides
        },
        'Announcements' => {
          component: 'AnnounceListItem',
          items:     aggregator.group_announcements
        }
      }
    }
    #
    @expandable_friends = {
      heading: 'Friends',
      url:     v2_users_path,
      tabs:    {
        'My friends' => {
          component: 'UserListItemWithPopup',
          items:     aggregator.friends,
        },
        'Suggested friends' => {
          component: 'UserListItemWithPopup',
          items:     aggregator.suggested_friends
        }
      }
    }
    #
    @expandable_challenges = {
      heading:   'Challenges',
      component: 'ChallengeListItem',
      url:       v2_challenges_path,
      items:     aggregator.challenges
    }
  end
end
