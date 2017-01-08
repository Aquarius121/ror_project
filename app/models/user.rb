# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  firstname              :string(255)
#  lastname               :string(255)
#  zip                    :string(255)
#  motorcycle_club        :string(255)
#  fb_id                  :integer
#  fb_token               :string
#  location               :string(255)
#  gender                 :string(255)
#  age                    :string(255)
#  about_me               :text
#  riding_preference      :string(255)
#  subscribed             :boolean
#  avatar_id              :integer
#  authentication_token   :string(255)
#  subscription_id        :integer
#  fb_friends_ids         :integer          default("{}"), is an Array
#  fb_fetched_at          :datetime
#  latitude               :decimal(9, 6)
#  longitude              :decimal(9, 6)
#  role_id                :integer
#  time_zone              :string(255)
#  device_tokens          :text             default("{}"), is an Array
#  fb_session_expired     :boolean          default("false")
#  app_settings           :hstore
#
class User < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  include Aggregatored
  include Extended

  validates_presence_of :firstname, :lastname
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, :async,
         :omniauth_providers => [:facebook]

  has_paper_trail :ignore => [:sign_in_count, :current_sign_in_at,
                              :last_sign_in_at, :current_sign_in_ip,
                              :last_sign_in_ip, :fb_fetched_at, :updated_at,
                              :latitude, :longitude]

  acts_as_voter


  has_many :affiliate
  has_many :friendship
  has_many :friend_as_follower, :class_name => 'User', :foreign_key => 'follower_id'
  has_many :friend_as_user, :class_name => 'User', :foreign_key => 'user_id'

  has_many :members
  has_many :clubs, through: :members
  has_many :announcements, through: :clubs

  has_many :referral_as_referral, :class_name => 'User', :foreign_key => 'referral_id'
  has_many :referral_as_user, :class_name => 'User', :foreign_key => 'user_id'
  has_many :user_riding_preferences

  has_many :shared_rides

  has_many :comments
  belongs_to :attachment, :class_name => 'User', :foreign_key => 'avatar_id'
  has_many :activity_as_follower, :class_name => 'User', :foreign_key => 'follower_id'
  has_many :activity_as_user, :class_name => 'User', :foreign_key => 'user_id'

  has_many :user_bikes
  accepts_nested_attributes_for :user_bikes, allow_destroy: true

  has_many :routes, -> { not_deleted }
  belongs_to :subscription
  has_one :user_location
  has_one :riding_group
  has_many :ranks
  has_many :challenges, through: :ranks

  enum gender: {male: 'Male', female: 'Female'},
       age: Hash[(0..120).map { |v| [v.to_s, v.to_s] }]

  delegate :genders, :ages, to: :class

  belongs_to_active_hash :role

  delegate :title, to: :role, prefix: true
  delegate :can?, :cannot?, to: :ability

  alias :avatar :attachment

  store_accessor :app_settings, :location_sharing, :notifications, :units

  attr_accessor :current_step, :code, :skip_code_check, :pending_avatar_update

  validates :units,
            inclusion: {in: %w{metric imperial}}, allow_blank: true, allow_nil: true

  # validates :password, confirmation: true, presence: true, if: -> { current_password.present? }
  # validate do
  #   update_with_password params if params
  # end

  scope :with_expiring_card, -> {
    includes(:subscription).
        where(['subscriptions.card_expires_at < ?', Date.today + 15.days]).
        where(['subscriptions.email_sent = ?', false]).
        references(:subscription)
  }

  scope :admins, -> {
    where(role_id: Role.find_by_name('Admin').id)
  }

  scope :free, -> {
    where(role_id: Role.find_by_name('Free').id)
  }
  scope :premium, -> {
    where(role_id: Role.find_by_name('Pro').id)
  }

  scope :with_active_subscription, -> {
    joins(:subscription).
        where('subscriptions.canceled_at is null').
        where('users.role_id not in (1,2)')
  }

  scope :search, ->(q) {
    where('firstname ILIKE ? OR lastname ILIKE ? or email ilike ?', q, q, q)
  }

  scope :close_to, ->(latitude, longitude, distance_in_meters = 25000) {
    where(%{
      ST_DWithin(
        ST_GeographyFromText(
          'SRID=4326;POINT(' || users.longitude || ' ' || users.latitude || ')'
        ),
        ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
        %d
      )
    } % [longitude, latitude, distance_in_meters])
  }

  scope :with_distance_to, ->(latitude, longitude) {
    select(
        %{ST_Distance(
          ST_GeographyFromText('SRID=4326;POINT(' || users.longitude || ' ' || users.latitude || ')'),
          ST_GeographyFromText('SRID=4326;POINT(%f %f)')
          ) as distance_between
        }% [longitude, latitude])
  }


  #validate :check_code

  delegate :reactify!, to: :aggregator

  def advanced_search(filter)
    query = User
    unless filter.name.empty?
      name = "%#{filter.name.strip}%"
      query = query.where('users.firstname ILIKE ? OR users.lastname ILIKE ? OR users.firstname || \' \' || users.lastname ILIKE ?', name, name, name)
    end
    unless filter.location.empty?
      query = query.where('users.location ILIKE ? OR users.zip ILIKE ?', "%#{filter.location}%", "%#{filter.location}%")
    end
    unless filter.bike_type_id.empty?
      query = query.joins(:user_bikes).where(user_bikes: {type_id: filter.bike_type_id})
    end
    # if params[:club_id].empty?
    # query = query
    #             .joins('LEFT OUTER JOIN members ON users.id = members.user_id AND members.active = TRUE')
    #             .joins('LEFT OUTER JOIN clubs ON members.club_id = clubs.id')
    # # else
    #   query = query.joins(member: :club).where(members: {club_id: params[:club_id], active: true})
    # end

    # unless params[:riding_preference].empty?
    #   query = query
    #               .joins(:user_riding_preferences)
    #               .where(user_riding_preferences: {preference_id: params[:riding_preference]})
    # end
    @users = query
                 .where('users.id <> ?', self.id)
                 .reorder('users.firstname').limit(100)
  end

  def friends_search(filter)
      advanced_search(filter).
          where("NOT EXISTS(#{Friendship.where(user_id: self.id).where('follower_id = users.id').to_sql})")
  end

  def reactify user
    @reactifier = user
    to_json only: [:id], methods: %i[
      full_name
      avatar_url
      location
      url
      bike
      stats
    ]
  end

  # TODO
  def location
    self[:location] || 'Eagle, Colorado'
  end

  # TODO
  def stats(user = nil)
    user ||= @reactifier
    @rides_stats ||= Route.select('count(*) as total_count, sum(ride_distance) as total_distance, sum(ride_time) as total_time').
        joins('LEFT JOIN "shared_rides" ON "shared_rides"."route_id" = "routes"."id"').
        where('"routes"."user_id" = ? OR "shared_rides"."user_id" = ?', self.id, self.id).to_a.first

    total_distance_in_meters = @rides_stats.total_distance || 0

    total_distance = user.units == 'metric' ?
        (total_distance_in_meters / 1000.0).round(1)
    :
        UnitsConverter.meters_to_mile(total_distance_in_meters)
    [
        {
            value: total_distance,
            units: UnitsConverter::DISTANCE_MAPPING[user.units],
            title: 'total distance'
        },
        {
            value: '35',
            units: UnitsConverter::VELOCITY_MAPPING[user.units],
            title: 'avg speed'
        },
        {
            value: UnitsConverter.seconds_to_screen(@rides_stats.total_time || 0),
            title: 'total time'
        },
        {
            value: @rides_stats.total_count,
            title: 'total rides'
        }
    ]
  end

  # TODO
  def bike
    user_bikes.first.try(:model)
  end

  def url
    route :v2_user_path, self
  end

  def ability
    @ability ||= Ability.new self
  end

  def riding_preferences
    user_riding_preferences.map(&:riding_preference)
  end

  # because we cannot use hmt-linkage
  def riding_preference_ids= ids
    self.user_riding_preferences = ids.map do |id|
      UserRidingPreference.new preference_id: id
    end
  end

  def riding_preference_ids
    user_riding_preferences.map &:preference_id
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.update_authentication_token
    end
  end

  def update_authentication_token
    self.authentication_token = generate_authentication_token
    self.save
  end

  def fb_friends
    @fb_friends ||= get_fb_friends
  end

  def friends
    site_friends = []
    users = User.joins(:friendship).where(friendships: {follower_id: id})
    site_friends += User.find(users.map(&:id) + fb_friends)
    site_friends.uniq { |x| x.id }
  end

  def is_friends_with?(friend)
    friend_id = friend.is_a?(User) ? friend.id : friend
    return true if friend_id == self.id || self.fb_friends.include?(friend_id)
    friendship = Friendship.approved(self.id, friend_id).count
    friendship == 2
  end

  # TODO
  # is used for checking ability
  def friends_ids
    [self.id]
    # ADD FRIENDSHIP
  end

  # is used for checking ability
  def clubs_ids
    clubs.map &:id
  end


  def followers_count
    Friendship.where(user_id: self.id).count
  end

  def following_count
    Friendship.where(follower_id: self.id).count
  end

  def rides_count
    @rides_count ||= self.routes.size
  end

  def recent_ride
    self.routes.order(:id).last
  end

  # TODO make_friends
  def make_friends_with(user)
    if self.is_friends_with?(user.id)
      :already_friends
    else
      Friendship.create({
                            user_id: user.id,
                            follower_id: self.id,
                            active: true,
                            date: Time.current
                        })

      if Friendship.is_friend_request?(self, user)
        NotificationMailer.delay.friendship_request_approve_email(user.id, self.id)
        args = {:full_name => self.full_name}
        Activity.add_activity('activities/template/approve_friend', args, self.id, user.id)
        :request_approved
      else
        NotificationMailer.delay.friendship_request_email(user.id, self.id)
        :request_sent
      end
    end
  end

  # TODO unfriend
  def unfriend(user)
    true
  end

  # TODO join club
  def join(club)
    return true if Member.is_in_club?(club.id, self.id)
    Member.create({
                      club_id: club.id,
                      user_id: self.id,
                      active: club.privacy_id == 2
                  })
  end

  # TODO leave club
  def leave(club)
    Member.where(club_id: club.id, user_id: self.id).destroy_all
  end

  def rides_stats
    Route.select('count(*) as count, sum(ride_distance) as distance, sum(ride_time) as time')
        .joins('LEFT JOIN "shared_rides" ON "shared_rides"."route_id" = "routes"."id"')
        .where('("routes"."user_id" = ? AND "routes"."archived" = false) OR "shared_rides"."user_id" = ?', self.id, self.id)
        .to_a.first
  end

  def own_rides_stats
    Route.select('count(*) as count, sum(ride_distance) as distance, sum(ride_time) as time')
        .where('"routes"."user_id" = ? and completed = ? and archived = false', self.id, true)
        .all.to_a.first
  end

  def card_expires
    self.subscription && self.subscription.card_expires_at && self.subscription.card_expires_at < 15.days.from_now
  end

  def route_count_exceeded?
    self.role?(:free) && self.routes.count >= 999
  end

  def code
    @code || ''
  end

  def full_name
    "#{firstname} #{lastname}"
  end


  def self.find_for_facebook_oauth(access_token)
    data = access_token['extra']['raw_info']
    if user = User.find_by_email(data['email'])
      if !user.fb_token || !user.fb_id
        user.fb_token = access_token['credentials']['token']
        user.fb_id = data['id']
      elsif user.fb_token != access_token['credentials']['token']
        user.fb_token = access_token['credentials']['token']
      end
    else
      user = User.new(
          :email => data['email'],
          :firstname => data['first_name'],
          :lastname => data['last_name'],
          :fb_id => data['id'],
          :fb_token => access_token['credentials']['token']
      )
    end
    user.save if user.fb_id?
    user
  end

  def update_avatar(file = nil)
    if file == nil
      file = open(self.source_avatar_url, read_timeout: 2) rescue nil
    end
    return false unless file
    avatar = self.avatar_id? ? Attachment.find(self.avatar_id) : Attachment.new
    avatar.file = file
    if avatar.valid?
      avatar.save
    else
      return false
    end
    self.update_column(:avatar_id, avatar.id) if self.avatar_id != avatar.id
    true
  end

  def set_role(role_name)
    self.role = Role.find_by_name(role_name.to_s.camelize)
  end

  def update_with_password(params={})
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if params[:password].blank? || valid_password?(current_password)
               update_attributes(params)
             else
               self.attributes = params
               self.valid?
               self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
               false
             end

    clean_up_passwords
    result
  end

  def role?(role_name)
    !!(self.role.name == role_name.to_s.camelize)
  end

  def roles?(*role_names)
    !!role_names.any? { |rn| self.role.name == rn.to_s.camelize }
  end

  def premium!
    self.set_role :pro
    self.save!
  end

  def plus!
    self.set_role :plus
    self.save!
  end

  def free!
    self.set_role :free
    self.save!
  end

  def admin!
    self.set_role :admin
    self.save!
  end

  def notify_about_cc_expiration
    # not delay but deliver, because we are called from Sidekiq worker
    NotificationMailer.cc_expiration(self.id).deliver
    self.subscription.email_sent = true
    self.save!
  end

  def cc_expiration_notification_sent?
    self.subscription.email_sent
  end

  def update_cc_expiration(expires_at)
    self.subscription.card_expires_at = expires_at
    self.subscription.email_sent = false
    self.subscription.save
  end

  def save_device_token(token)
    tokens = self.device_tokens
    return if tokens.include? token
    tokens = tokens + [token]
    self.update(device_tokens: tokens.compact)
  end

  def remove_device_token(token)
    tokens = self.device_tokens
    return unless tokens.include? token
    tokens = tokens - [token]
    self.update(device_tokens: tokens.compact)
  end

  def start_avatar_update
    return if self.pending_avatar_update
    self.pending_avatar_update = true
    AvatarUpdater.perform_async(self.id)
  end

  def avatar_url(size = :small)
    'https://maps.ridingsocial.com/rever-icon.png'
    #self.avatar_id? ? Attachment.find(self.avatar_id).file.url(size) : self.avatar_source_url
  end

  def source_avatar_url
    @avatar_url ||= if self.fb_id?
                      uid = self.fb_id
                      "https://graph.facebook.com/#{uid}/picture?width=500&height=500"
                    else
                      gravatar_id = Digest::MD5::hexdigest(self.email).downcase
                      "https://gravatar.com/avatar/#{gravatar_id}?s=500&d=#{CGI.escape('https://maps.ridingsocial.com/rever-icon.png')}"
                    end
  end

  private

  # commented out as they decided to let free users create as many rides as they want
  # def undelete_routes
  #   self.routes.deleted.each {|r| r.archived = false; r.save!}
  # end

  def get_fb_friends
    return [] if self.fb_token.blank?
    return User.where({fb_id: self.fb_friends_ids}).pluck(:id) if self.fb_fetched_at && self.fb_fetched_at > 30.minutes.ago
    FacebookFriendsUpdater.perform_async(self.id)
    []
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.find_by(authentication_token: token)
    end
  end

  def check_code
    if self.new_record? && !self.skip_code_check
      if self.code != ''
        invite = Invite.find_by(:email => self.email, :code => self.code)
        errors.add(:code, 'is wrong.') if !invite
      else
        errors.add(:code, 'is empty.')
      end
    end
  end


end

