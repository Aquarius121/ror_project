class RegistrationsController < Devise::RegistrationsController
  layout 'signin'

  authorize_resource :class => Users
  skip_authorize_resource :only => [:new, :create, :invite, :inviterequest, :frominvite, :combined]
  skip_before_action :verify_authenticity_token, :only => [:inviterequest, :create]
  skip_before_action :authenticate_user!, :only => [:inviterequest, :create]
  before_action :prevalidate, only: [:create]

  def destroy
    user = current_user
    user = User.find(params[:id]) if params[:id] && current_user.role?(:admin)
    SharedRide.where({:user_id => user.id}).destroy_all
    SharedRide.where({:route_id => Route.select(:id).where({:user_id => user.id}).to_a}).destroy_all
    Route.where({:user_id => user.id}).destroy_all
    Member.where({:user_id => user.id}).destroy_all
    Friendship.where({:user_id => user.id}).destroy_all
    Friendship.where({:follower_id => user.id}).destroy_all
    UserRidingPreference.where({:user_id => user.id}).destroy_all
    Referral.where({:user_id => user.id}).destroy_all
    Referral.where({:referral_id => user.id}).destroy_all
    UserBike.where({:user_id => user.id}).destroy_all
    if (user.subscription)
      Payment.unsubscribe(user)
    end
    user.destroy
    if params[:id]
      redirect_to '/users'
    else
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message :notice, :destroyed if is_navigational_format?
      respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
    end
  end

  def new
    user_params = session[:user_params] || sign_up_params
    @user = User.new(user_params)
    render 'devise/registrations/new', layout: 'signin'
  end

  def frominvite
    invite = Invite.where('md5(cast(id as varchar(255))) = ?', params[:id]).first
    @user = User.new
    if invite
      @user.email = invite.email
      @user.firstname = invite.firstname
      @user.lastname = invite.lastname
      @user.code = invite.code
    end
    render 'new'
  end

  def invite
    @invite = Invite.new
    render 'invites/new'
  end

  def combined
    user_params = session[:user_params] || sign_up_params
    @user = User.new(user_params)
  end

  def inviterequest
    @invite = Invite.new({
                             email: params[:invite][:email],
                             firstname: params[:invite][:firstname],
                             lastname: params[:invite][:lastname]
                         })

    if @invite.valid?
      unless Invite.exists?(:email => params[:invite][:email])
        @invite.save
        NotificationMailer.delay.invite_to_admin(@invite.email, @invite.full_name, @invite.id)
        NotificationMailer.delay.invite_request(@invite.email, @invite.full_name)
      end
      respond_to do |format|
        format.html { redirect_to new_user_registration_path, notice: 'Request was sent.' }
        format.json { render :json => ['text' => 'Request was sent.'], :status => :ok }
      end
    else
      respond_to do |format|
        format.html { render 'invites/new' }
        format.json { render :json => ['text' => 'Bad request'], :status => :unprocessable_entity }
      end
    end
  end

  def create
    @user = User.new(sign_up_params)
    if @user.save
      @user.set_role :free
      @user.update_authentication_token
    end
    if @user.new_record?
      respond_to do |format|
        format.html { render params[:customer] == nil ? 'new' : 'combined' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    else
      if session['ref'] && session['ref'] > 0
        Referral.create(:user_id => session['ref'], :referral_id => @user.id)
        session.delete 'ref'
      end
      RegistrationMailer.delay.fb_registration_email(@user.id)
      sign_in(@user)

      ######
      if @plan
        payment_response, subs_response = Payment.subscribe(@plan, @card_num, @expiration, @cvv, current_user, @customer, @coupon)
        Rails.logger.info "payment_response.success?: #{payment_response.success?}"
        subs_response && Rails.logger.info("subs_response.success?: #{subs_response.success?}")

        response = subs_response || payment_response
        Rails.logger.info "response.response_reason_text: #{response.response_reason_text}"

        if response.success?
          subscription = Subscription.new(
              :transaction_id => response.subscription_id,
              :premium_plan => @plan,
              :card_expires_at => cc_expiration_date
          )
          if subscription.save
            @user.subscription = subscription
            @user.role = @plan.role
            @user.save!
            NotificationMailer.delay.subscription(@user.id)
            NotificationMailer.delay.cc_invoice(@user.id, payment_response.transaction_id, response.subscription_id, @plan.name, @plan.price)
          end
        else
          session[:signup_error] = response.response_reason_text
        end
      end
      ######

      target_url = authenticated_root_path + '#additional'
      if session_target_url = session['user_return_to']
        target_url = "#{target_url}$#{session_target_url[2..-1]}"
      end

      respond_to do |format|
        format.html { redirect_to target_url }
        format.json { render :status => 200, :json => {:token => @user.authentication_token} }
      end
    end
  end

  def update
    @user = User.find(params[:id]) if params[:id] && current_user.role?(:admin)
    self.resource = @user || resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    update_result = if params[:id] && current_user.role?(:admin)
                      params[:user].delete(:current_password)
                      if account_update_params[:password].blank?
                        params[:user].delete(:password)
                        params[:user].delete(:password_confirmation)
                      end
                      resource.update(account_update_params)
                    else
                      update_resource(resource, account_update_params)
                    end

    if update_result
      yield resource if block_given?
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
            :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end

      bikes = []
      bikes = ActiveSupport::JSON.decode(params[:user][:garage]) unless params[:user][:garage].blank?
      bikes = [] unless bikes.kind_of?(Array)
      my_bikes = @user.user_bikes.to_a
      my_bikes.each do |my_bike|
        my_bike.destroy unless bikes.any? { |bike| bike['name'] == my_bike.model && bike['type'] == my_bike.type_id }
      end
      bikes.each do |bike|
        unless my_bikes.any? { |my_bike| bike['name'] == my_bike.model && bike['type'] == my_bike.type_id }
          @user.user_bikes.create(model: bike['name'], type_id: bike['type'])
        end
      end

      preference = params[:user]['preference']
      preference = [] unless preference.kind_of?(Array)
      preference.map! { |p| p.to_i }

      user_prefs = @user.user_riding_preferences.to_a
      user_prefs.each do |p|
        p.destroy unless preference.include?(p.preference_id)
      end
      preference.each do |p|
        @user.user_riding_preferences.create(:preference_id => p) unless user_prefs.any? { |x| x.preference_id == p }
      end

      unless params[:id]
        sign_in resource_name, resource, :bypass => true
      end

      respond_to do |format|
        format.html { super }
        format.json { render :status => 200, :json => ['text' => resource, :status => 200] }
      end
    else
      clean_up_passwords resource
      #      respond_with resource
      respond_to do |format|
        format.html { super }
        format.json {
          render :json => ['text' => resource.errors.full_messages, :status => 422], :status => :unprocessable_entity
        }
      end
    end
  end

  def edit
    @user_id = params[:id]
    @user = User.find(@user_id) if @user_id
    render :template => 'devise/registrations/edit', :layout => false
  end


  private

  def cc_expiration_date
    month, year = @expiration[0..1], @expiration[2..3]
    Date.new(('20'+year).to_i, month.to_i) rescue nil
  end

  def prevalidate
    return unless params['card-num']
    @card_num = params['card-num']
    @customer = params[:customer].split(' ')
    @cvv = params[:cvv]
    @expiration = params[:month].to_s + params[:year].to_s
    @plan = PremiumPlan.find(params[:plan]) if params[:plan]

    unless cc_expiration_date
      session[:signup_error] = 'Card expiration date is invalid'
      return
    end
    session[:signup_error] = 'Card has expired' if Date.today > cc_expiration_date
  end

end
