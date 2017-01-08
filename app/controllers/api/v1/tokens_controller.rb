class Api::V1::TokensController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!

  respond_to :json

  #curl --data "fbtoken=CAAIdifzjFhoBAOL4JJ2eySzP4IZCAIUEbDALrgy4GzFfJmqZAVjnLoJI97U585t7ieCmjgZBcICYuE9OSM4GuaCBqsy5viIuVNir7OrnoqhMapWuW6j1MAI6n29bNN9aGH2GXVSdcWGISK95og4n9yn7bCrvOnZAZAaureqe3HUqAZC5oHtSBQ6lctNSdZBDcbAqg6YMVqsKioZCAPZCHeec6" https://maps.ridingsocial.com/api/v1/tokens.json -v
  #curl --data "fbtoken=CAAIdifzjFhoBAPDZCKFwh6ENOG8MLi66GljaEwVhtpexwiYqjsE9IlboPZBRjVM7MX5waM5r1RpEP51GNs2PrBuHZAfsGPuu6jAuQQXz5TWhhpdWl7ZAcNxJ42mFSRQK94grOHcvKXdOltjwqCM4D7ZAZBQOaoFdEbSR2ZATQlZCe2JflzRSU9Evc5IVUlepCMbnFWUN0cqH46to6YLtiatd" https://maps.ridingsocial.com/api/v1/tokens.json -v
  def create
    email = params[:email]
    password = params[:password]
    fb_token = params[:fbtoken]
    if request.format != :json
      render :status => 406, :json => {:message => 'The request must be json'}
      return
    end

    if (email.nil? or password.nil?) && fb_token.nil?
      render :status => 400,
             :json => {:message => 'The request must contain the user email and password or FB token.'}
      return
    end

    if fb_token
      #check token
      begin
        facebook_graph = ::Koala::Facebook::API.new('595428443887130|BMCDixQJlECImLZsnnxGBO2jtoI')
        @token_info = facebook_graph.debug_token(fb_token)
        logger.info @token_info.inspect
        @user = User.find_by(fb_id: @token_info['data']['user_id'])
      rescue => e
        logger.error e.message
        @user = nil
      end
    else
      @user = User.find_by(email: email.downcase)
    end

    if @user.nil?
      logger.info("User #{email || fb_token} failed signin, user cannot be found.")
      render :status => 401, :json => {:message => 'Invalid email or password or FB token.'}
      return
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    #@user.generate_authentication_token

    valid = (!fb_token && @user.valid_password?(password)) || (fb_token && @token_info['data']['app_id'] == '595428443887130')

    if valid
      @user.ensure_authentication_token
      logger.info 'Token: ' + @user.authentication_token.to_s
      @user.save_device_token(params[:device_token])
      render :status => 200, :json => {:token => @user.authentication_token, :email => @user.email, :premium => !@user.role?(:free)}
    else
      logger.info("User #{email} failed signin, password \"#{password}\" is invalid")
      render :status => 401, :json => {:message => 'Invalid email or password or FB token.'}
    end
  end

  def destroy
    @user = User.find_by(authentication_token: params[:id])
    if @user.nil?
      logger.info('Token not found.')
      render :status => 404, :json => {:message => 'Invalid token.'}
    else
      @user.update_authentication_token
      @user.remove_device_token(params[:device_token]) if params[:device_token]
      render :status => 200, :json => {:token => params[:id]}
    end
  end

end