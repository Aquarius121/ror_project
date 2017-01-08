class NotificationMailer < ActionMailer::Base
  default from: APP_CONFIG['site_email']
  layout 'mailer'

  def friendship_request_email(user_id, friend_id)
    @user = User.find user_id
    @friend = User.find friend_id
    @url = APP_CONFIG['base_url'] + '#friendship-approve'
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: 'You have a new friendship request!')
  end

  def friendship_request_approve_email(user_id, friend_id)
    @user = User.find user_id
    @friend = User.find friend_id
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: 'You have a new friendship confirmed!')
  end

  def copy_route(user_id, friend_id, route_id)
    @user = User.find user_id
    @friend = User.find friend_id
    @route = Route.find route_id
    @url = APP_CONFIG['base_url'] + "#route-#{@route.id}"
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: "#{@friend.full_name} copied your ride!")
  end

  def share_route(user_id, friend_id, route_id, message)
    @user = User.find user_id
    @friend = User.find friend_id
    @route = Route.find route_id
    @message = message
    @url = APP_CONFIG['base_url'] + "#route-#{@route.id}"
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: "#{@friend.full_name} shared a ride with you!")
  end

  def share_route_via_email(user_id, email, route_id)
    @user = User.find user_id
    @route = Route.find route_id
    @email = email
    @url = APP_CONFIG['base_url'] + "#route-#{@route.id}"
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: email, subject: "#{@user.full_name} shared a ride with you!")
  end

  def new_announcement(user_id, title = '', body = '', club_name = '')
    @user = User.find user_id
    @title = title
    @body = body
    @clubname = club_name
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: "New announcement in #{@clubname}!")
  end

  def invite(email, name, code, url)
    @email = email
    @name = name
    @code = code
    @url = APP_CONFIG['base_url'] + 'registrations/frominvite/' + url
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @email, subject: "#{@name}, Your invite approved!")
  end

  def invite_request(email, name)
    @email = email
    @name = name
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @email, subject: 'Your access request was saved!')
  end

  def invite_to_admin(email, name, id)
    emails = User.admins.where.not(users: {:id => ['11', '48', '44']}).pluck(:email).join(', ')
    @email = email
    @name = name
    @url = APP_CONFIG['base_url'] + 'invites/notapproved'
    @url_approve = APP_CONFIG['base_url'] + "invites/approve/#{id}"
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: '', bcc: emails, subject: "#{@name} requested invite!") do |format|
      format.html { render layout: nil }
    end
  end

  def subscription(user_id)
    @user = User.find user_id
    @email = @user.email
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @email, subject: 'Subscription Notification')
  end

  def unsubscription(user_id, subscription_id)
    @user = User.find user_id
    @subscription = Subscription.find subscription_id

    @email = @user.email
    if @subscription.coupon
      @price = Payment.percent_of(@subscription.premium_plan.price, @subscription.coupon.discount)
    else
      @price = @subscription.premium_plan.price
    end
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @email, subject: 'Unsubscribe notification')
  end

  def unsubscription_to_admins(user_id, subscription_id = nil)
    emails = User.admins.where.not(users: {:id => %w(11 48 44)}).pluck(:email).join(', ')
    @user = User.find user_id
    @subscription = Subscription.find_by(id: subscription_id)
    headers['X-MC-Track'] = 'opens'
    mail(to: '', bcc: emails, subject: "#{@user.full_name} canceled subscription") do |format|
      format.html { render layout: nil }
    end
  end

  def cc_operation(user_id, amount, description, reason)
    @user = User.find user_id
    @amount = amount
    @description = description
    @reason = reason
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: 'RidingSocial: subscription payment')
  end

  def cc_invoice(user_id, transaction_id, subscription_id, plan_name, amount)
    @user = User.find user_id
    @transaction_id = transaction_id
    @subscription_id = subscription_id
    @plan_name = plan_name
    @amount = amount
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: 'RidingSocial: subscription invoice')
  end

  def cc_expiration(user_id)
    @user = User.find user_id
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: 'RidingSocial: card is about to expire')
  end

  def subscription_suspended(user_id)
    @user = User.find user_id
    headers['X-MC-Track'] = 'opens, clicks_htmlonly'
    mail(to: @user.email, subject: 'RidingSocial: subscription payment')
  end

end
