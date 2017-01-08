# == Schema Information
#
# Table name: clubs
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  logo         :string(255)
#  description  :text
#  location     :string(255)
#  privacy_id   :integer
#  club_type_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  owner_id     :integer
#  logo_id      :integer
#  website      :string(255)
#  url          :string(255)
#

class Club < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  include Extended
  include Aggregatored

  belongs_to_active_hash :privacy
  belongs_to :club_type
  has_many :members, :dependent => :destroy
  belongs_to :user
  belongs_to :attachment, :class_name => 'Club', :foreign_key => 'logo_id'
  has_many :announcements
  has_many :club_riding_preferences, :dependent => :destroy
  has_many :group_rides
  has_many :routes, through: :group_rides

  validates :title, presence: true


  def self.advanced_search(filter)
    query = Club
    t = Club.arel_table
    if filter.name != ''
      query = query.where(t[:title].matches("%#{filter.name}%"))
    end
    if filter.location != ''
      query = query.where(t[:location].matches("%#{filter.location}%"))
    end
    if filter.club_type_id != ''
      query = query.where(t[:club_type_id].eq(filter.club_type_id))
    end
    #TODO Rewrite query
    @clubs = query
                 .select("clubs.*, count(DISTINCT members.user_id) as users_count, club_types.title as club_type_name, count(DISTINCT routes.id) as routes_count")
                 .group("clubs.id, members.club_id, club_types.id")
                 .joins(:club_type)
                 .joins('LEFT OUTER JOIN "members" ON "members"."club_id" = "clubs"."id" and "members"."active" = TRUE')
                 .joins('LEFT OUTER JOIN "routes" ON "members"."user_id" = "routes"."user_id"')
                 .limit(100)
                 .distinct("clubs.id")
  end

  def reactify user=nil
    @reactifier = user
    to_json only: [:title, :id], methods: [
      :stats, :url, :avatar_url, :member_since
    ]
  end

  def member_since
    user ||= @reactifier
    members.find_by(user_id: user.id).try(:created_at).try :to_formatted_s, :date_short
  end

  # TODO
  # invite users by array of ids
  def invite ids
    true
  end

  def url
    route :v2_club_path, self
  end

  # TODO
  def avatar_url(size = :medium)
    self.logo_id? ? Attachment.find(self.logo_id).file.url(size) : '/images/club.png'
  end

  def update_logo(file = nil)
    if self.logo_id?
      logo = Attachment.find(self.logo_id)
      logo.update_attribute(:file, file)
    else
      logo = Attachment.new(:file => file)
      logo.save
      self.logo_id = logo.id
      self.save
    end
  end

  def is_owner?(user)
    self.owner_id == user.id
  end

  def list_members
    User.joins(:members).where(members: {club_id: self.id, active: true})
  end

  def waiting_for_approvement
    Member.where(club_id: self, active: false).count
  end

  def is_member?(user)
    Member.where(club_id: self, user_id: user, active: true).any?
  end

  def waits_for_approvement
    Member.where(club_id: self, user_id: user_id, active: false).any?
  end

  def stats(user = nil)
    user ||= @reactifier
    club_stats = Route.ride_stats_for_club(self).to_a.first
    total_distance_in_meters = club_stats.total_distance || 0
    units = user.units
    total_distance = units == 'metric' ?
        (total_distance_in_meters / 1000.0).round(1)
    :
        UnitsConverter.meters_to_mile(total_distance_in_meters)

    [
        {
            value: total_distance,
            units: UnitsConverter::DISTANCE_MAPPING[units],
            title: 'total distance'
        },
        {
            value: UnitsConverter.seconds_to_screen(club_stats.total_time || 0),
            title: 'total time'
        },
        {
            value: club_stats.total_rides,
            title: 'total rides'
        }
    ]
  end

  def rides_count
    Route.for_members_of_club(self).count
  end

  def total_time
    Route.for_members_of_club(self).sum(:ride_time)
  end

  def total_distance
    Route.for_members_of_club(self).sum(:ride_distance)
  end

  def riding_preferences
    club_riding_preferences.map{|p| p.riding_preference.title}.join(', ')
  end

end
