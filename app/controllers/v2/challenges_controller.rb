class V2::ChallengesController < V2Controller
  before_action :set_challenge, only: :show

  def show
    aggregator = @challenge.aggregator true

    @info = {
      heading: 'Challenge details',
      tabs:    {
        'Leaderboard' => {
          component: 'Leaderboard',
          item:      aggregator.leaderboard
        },

        'Rules' => @challenge.rules,
        'Prize' => @challenge.prize

      }
    }
  end

  # TODO challenges list
  def index
  end

  # TODO accept challenge
  def accept
  end

  # TODO accept challenge
  def cancel
  end

  private
  def set_challenge
    @challenge = Challenge.find params[:id]
  end
end
