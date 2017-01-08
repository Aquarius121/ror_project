class ClubAggregator < BaseAggregator
  # @members_count = User.eager_load(:member).where(members: {:club_id => @club.id, :active => true}).count
  # @rides_count = Route.eager_load(:user => :member).where(members: {:club_id => @club.id, :active => true}).count

  # TODO leaderboard
  def leaderboards
    []
  end

  def members
    User.eager_load(:members).
      where \
        members: {
          club_id: @instance.id,
          active:  true
        }
  end

  # TODO upcoming rides
  # @vic - done
  def upcoming_rides
    @instance.group_rides
  end

  # TODO announcements
  # @vic - done
  def announcements
    @instance.is_member?(@user) ? @instance.announcements : []
  end

  # TODO stats
  # @vic - done
  def stats(user = nil)
    @instance.stats(user||@user).map &:to_json
  end

  wrap except: [:stats]
end
