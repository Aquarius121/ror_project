class UserAggregator < BaseAggregator
  def groups
    @instance.clubs
  end

  def group_rides
    raw_groups.map(&:routes).flatten
  end

  def group_announcements
    @instance.announcements
  end

  def friends
    @instance.friends
  end

  # TODO suggested friends
  # @vic - done
  def suggested_friends(limit=9)
    Friendship.suggest(@instance).take(limit)
  end

  # TODO challenges
  # @vic - why TODO here, user.challenges is OK
  def challenges
    @instance.challenges
  end

  def rides
    Route.own_for_user(@instance.id)
  end

  # TODO planned rides
  def planned_rides
    Route.own_for_user(@instance.id).where(completed: false)
  end

  # TODO tracked rides
  def tracked_rides
    Route.own_for_user(@instance.id).where(completed: true)
  end

  def shared_rides
    SharedRide.for_user(@instance.id).map(&:route).flatten
  end

  # TODO announces
  def announcements
    Announcement.all
  end

  # TODO stats
  def stats(user = nil)
    @instance.stats(user||@user).map &:to_json
  end

  wrap except: [:stats]
end
