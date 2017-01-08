class UsersController < ApplicationController
  load_and_authorize_resource :except => [:show]
  before_action :render_not_found, :only => [:index, :all_emails]
  before_action :set_user, :only => [:promote_to_admin, :make_pro, :demote_to_free]
  layout 'manage', only: [:index, :all_emails]

  helper_method :sort_column, :sort_direction

  def index
    @users = if params[:q]
      q = "%#{params[:q]}%"
      User.search(q)
    else
      User.all
    end
    @users = @users.includes(subscription: [:premium_plan])
    if params[:sort]
      @users = @users.order(params[:sort] + ' ' + sort_direction)
    else
      @users = @users.order(id: :desc)
    end

    @totals = Hash.new 0
    @users.each do |user|
      role_name = user.role.name
      role_name = role_name + ' (free)' if role_name == 'Pro' && !user.subscription
      @totals[role_name] = @totals[role_name] + 1
    end
    @totals['Total'] = @users.count
    @totals = Hash[@totals.sort]
    @users = @users.page(params[:page]).per(100)
  end

  def show
    show_current_user = params[:id] == 'me' || !current_user.role?(:admin)
    @user = show_current_user ? current_user : User.find(params[:id])
    recent_ride = current_user.routes.where(completed: true).order(:id).last
    @recent_ride = recent_ride ? recent_ride.title : nil
    @rides_stats = current_user.rides_stats
  end

  def search
    @params = params
    query = User
    unless params[:name].blank?
      name = params[:name].strip
      name = "%#{name}%"
      query = query.where('users.firstname ILIKE ? OR users.lastname ILIKE ? OR users.firstname || \' \' || users.lastname ILIKE ?', name, name, name)
    end
    unless params[:location].blank?
      query = query.where('users.location ILIKE ? OR users.zip ILIKE ?', "%#{params[:location]}%", "%#{params[:location]}%")
    end
    unless params[:bike_type].blank?
      query = query.joins(:user_bikes).where(user_bikes: {type_id: params[:bike_type]})
    end
    if params[:club_id].blank?
      query = query
      .joins('LEFT OUTER JOIN members ON users.id = members.user_id AND members.active = TRUE')
      .joins('LEFT OUTER JOIN clubs ON members.club_id = clubs.id')
    else
      query = query.joins(member: :club).where(members: {club_id: params[:club_id], active: true})
    end

    unless params[:riding_preference].blank?
      query = query
      .joins(:user_riding_preferences)
      .where(user_riding_preferences: {preference_id: params[:riding_preference]})
    end
    @users = query
    .where('users.id <> ?', current_user.id)
    .joins('LEFT OUTER JOIN routes ON routes.user_id = users.id')
    .group('users.id')
    .select('users.id, users.created_at, users.updated_at, users.firstname, users.lastname, users.location, users.avatar_id, users.fb_id, users.email, MIN(clubs.title) as club_name, COUNT(routes.id) as routes_count, SUM(routes.ride_distance) as distance')
    .reorder('users.firstname').limit(100)
  end

  def additional
    if current_user
      render :template => 'devise/registrations/additional', :layout => false
    end
  end

  def is_premium
    if request.xhr? || request.format == 'application/json'
      if current_user
        if current_user.role? :free
          render :json => { premium: false, description: 'the user is free account' }
        else
          render :json => { premium: true }
        end
      else
        render :json => {premium: false, error: 'User not found'}, :status => 500
      end
    else
      redirect_to root_path
    end
  end

  def role
    if (request.xhr? || request.format == 'application/json') && current_user
      render :json => { role: current_user.role.name.downcase }
    else
      render :json => {premium: false, error: 'User not found'}, :status => 404
    end
  end

  def promote_to_admin
    @user.admin! if @user.role? :free
    redirect_to :back, notice: @user && @user.role?(:admin) ? 'Success' : 'Failed'
  end

  def make_pro
    @user.premium! if @user.role? :free
    redirect_to :back, notice: @user && @user.role?(:pro) ? 'Success' : 'Failed'
  end

  def demote_to_free
    @user.free! if @user.roles?(:admin, :pro) && !@user.subscription
    redirect_to :back, notice: @user && @user.role?(:free) ? 'Success' : 'Failed'
  end

  def all_emails
    @emails = User.pluck(:email)
  end


  private
  def set_user
    @user = User.find(params[:id])
  end

  def render_not_found
    render :nothing => true, :status => 404 unless current_user.role? :admin
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'desc'
  end

  def sort_column
    sort = params[:sort]
    valid = sort && sort.split(',').all? {|s| User.column_names.include? s}
    valid ? sort : 'id'
  end

end