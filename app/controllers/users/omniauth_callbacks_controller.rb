class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    #    raise request.env["omniauth.auth"]['extra'].to_yaml
    @user = User.find_for_facebook_oauth request.env['omniauth.auth']
    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', :kind => 'Facebook'
      sign_in_and_redirect @user, :event => :authentication
    elsif @user.fb_id?
      flash[:notice] = "We got your information from Facebook, you can change it or just go ahead and create an account with us."
      session[:user_params] = {}
      session[:user_step] = nil
      session[:user_params][:email] = @user.email
      session[:user_params][:firstname] = @user.firstname
      session[:user_params][:lastname] = @user.lastname
      session[:user_params][:fb_id] = @user.fb_id
      session[:user_params][:fb_token] = @user.fb_token
      redirect_to new_user_registration_url
    else
      session['devise.facebook_data'] = env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end  
end
