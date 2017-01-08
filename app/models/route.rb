# == Schema Information
#
# Table name: routes
#
#  id                      :integer          not null, primary key
#  title                   :string(255)
#  difficulty              :string(255)
#  rating                  :float
#  elevation               :string(255)
#  ridedate                :date
#  description             :text
#  privacy_id              :integer
#  condition_id            :integer
#  created_at              :datetime
#  updated_at              :datetime
#  data                    :text
#  user_id                 :integer
#  surface_id              :integer
#  ride_distance           :integer
#  ride_time               :integer
#  completed               :boolean          default("false")
#  ride_type_id            :integer
#  encoded_path            :string(4096)
#  is_readonly             :boolean          default("false")
#  archived                :boolean          default("false"), not null
#  latitude                :decimal(9, 6)
#  longitude               :decimal(9, 6)
#  max_lean                :integer
#  likes_counter           :integer
#  cached_votes_total      :integer          default("0")
#  cached_votes_score      :integer          default("0")
#  cached_votes_up         :integer          default("0")
#  cached_votes_down       :integer          default("0")
#  cached_weighted_score   :integer          default("0")
#  cached_weighted_total   :integer          default("0")
#  cached_weighted_average :float            default("0.0")
#  average_speed           :float
#  max_speed               :float
#

require 'fileutils'
require 'googlemaps_polyline/core'


class Route < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  include Extended

  acts_as_votable

  belongs_to_active_hash :privacy
  belongs_to_active_hash :surface
  belongs_to_active_hash :ride_type #["User", "Butler", "Road", "G1"]

  belongs_to :condition
  belongs_to :user

  has_many :shared_ride
  has_many :comments
  has_one :gallery
  accepts_nested_attributes_for :gallery, allow_destroy: true

  default_scope { where(archived: false) }

  before_save :simplify_route_data, if: :ok_to_simplify?
  before_save :generate_encoded_path, :calc_distance, :calc_elevation, :set_privacy
  before_save :extract_coordinates, if: :g1?

  after_save :generate_thumbnail, if: -> { !archived? }

  validate :route_count_within_limit, :on => :create
  validates :data, :title, presence: true

  scope :all_for_user, ->(user_id) {
    joins('LEFT JOIN "shared_rides" ON "shared_rides"."route_id" = "routes"."id"').
        where('"routes"."user_id" = ? OR "shared_rides"."user_id" = ?', user_id, user_id)
  }

  scope :deleted, -> { where(archived: true) }
  scope :not_deleted, -> { where(archived: false) }

  scope :without_data, -> {
    select('"routes".id, title, rating, elevation, ridedate, description,
  privacy_id, condition_id, "routes".created_at, "routes".updated_at,ride_type_id,
  "routes".user_id, surface_id, ride_distance, ride_time, completed, encoded_path, is_readonly,
   CASE WHEN ride_type_id=4 THEN data ELSE null END AS data')
  }

  scope :for_index, -> {
    select('"routes"."id"', :title, :user_id, :ridedate, :description, :privacy_id, :condition_id, :firstname, :lastname)
        .joins(:user).references(:user)
  }

  scope :own_for_user, ->(user_id) { where(user_id: user_id) }
  scope :by_created_at, -> { order('routes.created_at desc') }
  scope :by_ridedate, -> { reorder(ridedate: :desc) }
  scope :for_friend, ->(friend_id) { where(user_id: friend_id, privacy_id: [2, 3]) }
  scope :g1, -> { where(ride_type_id: 4) }
  scope :butler, -> { where(ride_type_id: 2) }
  scope :close_to, ->(latitude, longitude, distance_in_meters = 200000) {
    where(%{
      ST_DWithin(
        ST_GeographyFromText(
          'SRID=4326;POINT(' || routes.longitude || ' ' || routes.latitude || ')'
        ),
        ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
        %d
      )
    } % [longitude, latitude, distance_in_meters]).limit(5)
  }

  def route_count_within_limit
    if self.user.role?(:free) && self.user.routes(:reload).not_deleted.count >= 999
      errors.add(:base, 'Exceeded route limit')
    end
  end

  def reactify user
    to_json only: [:title], methods: %i[
      url
      avatar_url
      date
      stats
      edit_url
      view_url
    ]
  end

  def edit_url
    route :edit_v2_ride_path, self
  end

  def view_url
    route :v2_ride_path, self
  end


  def date
    ridedate.to_datetime.to_formatted_s(:date_short) rescue ''
  end

  # TODO avatar url
  def avatar_url
    static_map_url('360x202')
  end

  # TODO stats in user's units
  def stats
    [ride_distance, ride_time]
  end

  def url
    route :v2_ride_path, self
  end

  def self.for_members_of_club(club)
    Route.joins('LEFT OUTER JOIN "users" ON "users"."id" = "routes"."user_id" LEFT OUTER JOIN "members" ON "members"."user_id" = "users"."id"').
        where(members: {:club_id => club, :active => true})
  end

  def self.ride_stats_for_club(club)
    Route.for_members_of_club(club).
        select(Route.arel_table[:ride_distance].sum.as("total_distance"),
               Route.arel_table[:ride_time].sum.as("total_time"),
               Route.arel_table[:id].count.as("total_rides")
        )
  end

  def self.friend_rides(user, friend_id)
    return [] unless user.is_friends_with?(friend_id)
    Route.for_friend(friend_id)
  end

  def self.search(title, location, type, current_user)
    query = Route.without_data.not_deleted
    query = query.where('title ILIKE ?', "%#{title}%") unless title.blank?
    query = query.where('data ILIKE ?', "%#{location}%") unless location.blank?

    if type == '2'
      query = query.where(:user_id => current_user.id, :completed => true)
    elsif type == '3'
      query = query.joins(:shared_ride).where(shared_rides: {user_id: current_user.id})
    elsif type == '1'
      query = query.where(:user_id => current_user.id, :completed => false)
    else
      query = query.select('sh2.id as is_shared').
          joins('LEFT JOIN "shared_rides" ON "shared_rides"."route_id" = "routes"."id"').
          joins("LEFT JOIN shared_rides sh2 ON sh2.route_id = routes.id and sh2.user_id = #{current_user.id}").
          where('"routes"."user_id" = ? OR "shared_rides"."user_id" = ?', current_user.id, current_user.id)
    end

    query.order('"routes"."created_at"')
  end

  def self.search_butler(title, location, type)
    types = type.blank? ? %w(2 4 5) : [type]
    query = Route.not_deleted.where(:ride_type_id => types)
    if title != ''
      query = query.where('title ILIKE ?', "%#{title}%")
    end
    if location != ''
      query = query.where('data ILIKE ?', "%#{location}%")
    end
    query = query.limit(50) if (title.blank? && location.blank?)
    query
  end

  def self.type_of_my_ride(ride, current_user)
    if ride.user_id == current_user.id && ride.completed == true
      return 'ridden'
    elsif ride.user_id == current_user.id
      return 'created'
    elsif SharedRide.where({:route_id => ride.id, :user_id => current_user.id}).count == 1
      return 'shared'
    end
    return ''
  end

  def private?
    self.privacy_id == 1
  end

  def g1?
    self.ride_type_id == 4
  end

  def my_ride_type(current_user)
    return '' unless current_user
    return 'ridden' if self.user_id == current_user.id && self.completed
    return 'created' if self.user_id == current_user.id
    return 'shared' if (self.has_attribute?(:is_shared) && self.is_shared > 0) || SharedRide.where({:route_id => self.id, :user_id => current_user.id}).count == 1
    ''
  end

  def to_g1_point
    data = self.decoded_route_data
    return nil unless data
    return nil unless data['origin']
    data['origin'].merge({
                             id: self.id,
                             title: self.title,
                             updated_at: self.updated_at.to_time.to_i
                         })
  end

  def start_location
    return nil if self.data.blank? || self.data == '{}'
    data = self.decoded_route_data
    "#{data['origin']['latitude']},#{data['origin']['longitude']}"
  end

  def nearby_butler_rides
    origin = self.decoded_route_data['origin']
    v = Vincenty.new(origin['latitude'], origin['longitude'])

    Route.butler.select do |r|
      data = ActiveSupport::JSON.decode(r.data)
      wp = (data['waypoints'] || [])
      wp << data['origin']
      wp << data['destination']
      points = data['route_data']
      wp = wp.map { |p| [p['latitude'], p['longitude']] }
      points = points || wp
      lat_min_max = points.minmax { |a, b| a[0] <=> b[0] }
      lng_min_max = points.minmax { |a, b| a[1] <=> b[1] }
      (lat_min_max + lng_min_max).any? do |p|
        v.sphericalDistanceAndAngle(Coordinate.new(p[0], p[1])).distance < 200000
      end
    end.first 5
  end

  def nearby_g1_descriptions
    origin = self.decoded_route_data['origin']
    Route.g1.where.not(id: self.id).close_to(origin['latitude'], origin['longitude'])
  end

  def calc_distance
    return if self.ride_distance
    points = extract_points
    return unless points
    return if points.length < 2
    current = points.shift
    self.ride_distance = points.inject(0) do |distance, point|
      v = Vincenty.new(current.first, current.last)
      c = Coordinate.new(point.first, point.last)
      delta = v.distanceAndAngle(c).distance
      distance += delta.nan? ? 0 : delta
      current = point
      distance
    end
  end

  def set_privacy
    self.privacy_id = 2 if self.ride_type_id == 2
  end

  def calc_elevation
    if self.elevation.blank? || self.elevation == 0
      begin
        points = extract_points
        return unless points
        return if points.length == 0
        path = ServerSideGoogleMaps::Path.new(points.map { |p| ServerSideGoogleMaps::Point.new(p[0], p[1]) })
        path = path.interpolate(199) if points.length > 199
        elevation_path = path.elevations([499, points.length].min)
        initial = elevation_path.points.shift.elevation
        self.elevation = elevation_path.points.inject(0) do |elevation, point|
          delta = point.elevation - initial
          elevation += delta if delta > 0
          initial = point.elevation
          elevation
        end
      rescue => e
        Airbrake.notify_or_ignore(e)
      end
    end
  end

  def decoded_route_data
    @decoded_route_data ||=
        self.data.blank? ? nil : ActiveSupport::JSON.decode(self.data)
  end

  def generate_encoded_path
    return unless self.encoded_path.blank?
    return unless self.decoded_route_data
    data = decoded_route_data
    points = data['route_data']
    if points && points.length > 0
      point_list = PointList.new(points.map { |p| p.reverse.map { |l| l.to_f } })
      encoded_polyline = point_list.to_s
      while encoded_polyline.length > 1500 do
        point_list = point_list.simplify
        encoded_polyline = point_list.to_s
      end
      self.encoded_path = encoded_polyline
    end
  end

  def ok_to_simplify?
    self.decoded_route_data && !self.completed? && decoded_route_data['route_type'] == 'directions'
  end

  def simplify_route_data
    return unless self.decoded_route_data
    data = decoded_route_data
    points = data['route_data']
    if points && points.length > 0
      point_list = PointList.new(points.map { |p| p.reverse.map { |l| l.to_f } })
      point_list = point_list.simplify
      data['route_data'] = point_list.tuple_array.map { |p| p.reverse }
      self.data = data.to_json
    end
  end

  def simplify_route_data2
    err = 0.000001 * 0.00001
    return unless self.decoded_route_data
    data = decoded_route_data
    points = data['route_data']
    if points && points.length > 0
      points = points.map do |p|
        p.length > 2 ?
            ServerSideGoogleMaps::Point.new(p[0], p[1], elevation: p[2])
        :
            ServerSideGoogleMaps::Point.new(p[0], p[1])
      end
      path = ServerSideGoogleMaps::Path.new(points).simplify(err)
      data['route_data'] = path.points.map { |p| [p.latitude, p.longitude, p.elevation].compact }
      self.data = data.to_json
      self.save!
    end
  end

  def static_map_url(size = '608x358')
    if !self.encoded_path.blank?
      params = "&path=weight:7|color:0xD76020FF|enc:#{self.encoded_path}"
    else
      begin
        center = self.start_location
        return '' if center.blank?
        params = "&zoom=12&center=#{center}"
      rescue => e
        logger.info e
        return ''
      end
    end
    [
        'https://maps.google.com/maps/api/staticmap?size=', size,
        '&maptype=roadmap&format=jpg',
        params
    ].join('')
  end

  def generate_thumbnail
    dir = File.join(Rails.root, 'public', 'system', 'routes')
    FileUtils.mkdir_p(dir)
    file = "fb-#{id}.png"
    host = "localhost#{Rails.env.development? ? ':3000' : ''}"
    url = "http://#{host}/embed/shot/#{id}"
    if Rails.env.development?
      Webshot.perform_in(20000, url, "#{File.join(dir, file)}")
    else
      Webshot.perform_async(url, "#{File.join(dir, file)}")
    end
  end

  def find_nearby_routes
    NearbyRoutes.perform_async(self.id) if self.g1? and !self.data.blank?
  end

  def extract_coordinates
    origin = self.decoded_route_data['origin']
    return unless origin
    self.latitude = origin['latitude']
    self.longitude = origin['longitude']
  end

  def extract_points
    return nil unless self.decoded_route_data
    self.decoded_route_data['route_data']
  end

  def extract_waypoints
    return nil unless self.decoded_route_data
    data = self.decoded_route_data
    (data['waypoints'] || []) + data['origin'] + data['destination']
  end

end

