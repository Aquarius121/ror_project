require 'open-uri'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery # http://jamescpoole.com/2013/10/31/rails-4-csrf-protection-with-clients-using-apis/
  #skip_before_filter :verify_authenticity_token, if: :app_request?

  before_action :authenticate_user_from_token!
  before_action :authenticate_user!

  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_action :check_referral
  before_action :check_hash_redirects
  # around_action :user_time_zone, :if => :current_user
  around_filter :set_time_zone

  rescue_from CanCan::AccessDenied do |exception|
    render text: 'Access is not granted.'
  end

  protected

  def set_time_zone
    old_time_zone = Time.zone
    Time.zone = (current_user.time_zone.presence || old_time_zone) if user_signed_in?
    yield
  ensure
    Time.zone = old_time_zone
  end

  def user_for_paper_trail
    # Save the user responsible for the action
    user_signed_in? ? current_user.id : 'Guest'
  end

  def after_sign_in_path_for(resource_or_scope)
    session['user_return_to'] || '/#dashboard'
  end

  def configure_devise_permitted_parameters
    registration_params = [:firstname, :lastname, :email, :password, :password_confirmation, :zip, :location, :gender, :age, :about_me, :motorcycle_club, :riding_preference, :subscribed, :avatar_id, :code, :fb_id, :fb_token, :time_zone]

    if params[:action] == 'update'
      devise_parameter_sanitizer.for(:account_update) {
          |u| u.permit(registration_params << :current_password)
      }
    elsif params[:action] == 'create'
      devise_parameter_sanitizer.for(:sign_up) {
          |u| u.permit(registration_params)
      }
    end
  end

  def check_hash_redirects
    if request.fullpath == '/?subscription' || /\/?route-(?<route_id>\d+)/ =~ request.fullpath
      target_url = request.fullpath == '/?subscription' ? '/#subscription' : "/#route-#{route_id}"
      if current_user
        session.delete 'user_return_to'
        redirect_to target_url
      end
      session['user_return_to'] = target_url
    end
  end


  def check_referral
    if params['ref'] && params['ref'] != ''
      ref_user = User.find_by('md5(cast(id as varchar(255))) = ?', params['ref'])
      if ref_user
        session['ref'] = ref_user.id
        redirect_to new_user_session_path
      end
    end
  end

  def can_access_comments?(route, user)
    return false unless route
    route.user_id == user.id ||
        route.privacy_id.to_f == 2 ||
        (route.privacy_id.to_f == 3 && user.is_friends_with?(route.user_id)) ||
        SharedRide.where({:user_id => user.id, :route_id => route.id}).count > 0
  end

  private

  #def app_request?
  #  user_email = params[:user_email].presence
  #  user = user_email && User.find_by(email: user_email)
  #  user && Devise.secure_compare(user.authentication_token, params[:user_token])
  #end

  def log_headers
    #logger.info params.to_yaml
    logger.info 'Content-Type: ' + request.headers['Content-Type'].to_s
    logger.info 'X-CSRF-Token: ' + request.headers['X-CSRF-Token'].to_s
  end

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user = user_email && User.find_by(email: user_email.downcase)
    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      sign_in user, store: false
    elsif user
      logger.info params.to_yaml
      logger.info 'Content-Type: ' + request.headers['Content-Type'].to_s
      logger.info 'X-CSRF-Token: ' + request.headers['X-CSRF-Token'].to_s
    end
  end


  def redis
    Redis.current
  end

end
