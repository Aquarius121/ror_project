# == Schema Information
#
# Table name: challenges
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  start_at    :datetime
#  end_at      :datetime
#  target      :float
#  featured    :boolean
#  prize       :string
#  sponsor     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  rules       :string
#  location    :string
#

class Challenge < ActiveRecord::Base
  include Aggregatored
  include Extended

  has_many :ranks
  has_many :users, through: :ranks
  default_scope { where(['end_at is null or end_at > ?', Time.now]) }

  after_initialize :defaults

  def reactify user=nil
    to_json only: [:id, :name, :description],
      methods: %i[url accept_url join_group_url]
  end

  def url
    route :v2_challenge_path, self
  end

  def location
    'Eagle, Colorado'
  end

  def avatar_url
    '/images/challenge.png'
  end

  def accept_url
    route :accept_v2_challenge_path, self
  end

  def join_group_url
    route :join_v2_club_path, group if self.try :group
  end

  # it's not "defaults", it's just mockups
  def defaults
    self.rules ||= 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sollicitudin justo vel pretium vestibulum. Ut eget velit eget risus pretium facilisis. Integer ut erat eros. Aliquam suscipit velit quis nisi varius sollicitudin. Nam maximus hendrerit arcu. Sed aliquet volutpat tellus convallis ullamcorper. '
    self.prize ||= 'Praesent odio odio, efficitur quis nisi quis, fermentum auctor orci. Aliquam volutpat vel urna non mollis. Nulla facilisis lacus sapien, eget congue ipsum fermentum eu. Maecenas venenatis eu est non maximus. Donec laoreet ullamcorper enim, quis ultricies metus tincidunt vitae'
  end

end
