class ChallengeAggregator < BaseAggregator
  # TODO leaderboards
  def leaderboard
    @instance.ranks.order(:rank).map do |r|
      {rank: r.rank, full_name: r.user.full_name, total_data: r.total_data }
    end
  end

  wrap except: [:leaderboard]
end
