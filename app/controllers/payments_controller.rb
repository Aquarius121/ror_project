class PaymentsController < ApplicationController

  before_action :is_xhr, only: [:subscribe, :update_subscription]
  before_action :prevalidate, only: [:subscribe, :update_subscription]

  def subscribe
    if current_user.subscription
      render json: {error: 'You already have an active subscription. Try refreshing the page.'}, :status => 500
      return
    end

    payment_response, subs_response = Payment.subscribe(@plan, @cart_num, @expiration, @cvv, current_user, @customer, @coupon)
    Rails.logger.info "payment_response.success?: #{payment_response.success?}"
    subs_response && Rails.logger.info("subs_response.success?: #{subs_response.success?}")

    response = subs_response || payment_response
    Rails.logger.info "response.response_reason_text: #{response.response_reason_text}"

    if @coupon
      price = self.percent_of(@plan.price, @coupon.discount).to_i
    else
      price = @plan.price
    end
    if response.success?
      subscription = Subscription.new(
          :transaction_id => response.subscription_id,
          :premium_plan => @plan,
          :card_expires_at => cc_expiration_date,
          :coupon_id => @coupon ? @coupon.id : nil
      )
      if subscription.save
        current_user.subscription = subscription
        current_user.role = @plan.role
        current_user.save!
        NotificationMailer.delay.subscription(current_user.id)
        NotificationMailer.delay.cc_invoice(current_user.id, payment_response.transaction_id, response.subscription_id, @plan.name, price)
        render json: {success: true}
      else
        render json: {error: 'Dont save'}
      end
    else
      render json: {success: false, error: response.response_reason_text}
    end
  end

  def update_subscription
    gateway_response = Payment.update_subscription(@cart_num, @expiration, @cvv, current_user, @customer)
    if gateway_response.success?
      current_user.update_cc_expiration(@expiration)
      render json: {success: true}
    else
      render json: {success: false, error: gateway_response.response_reason_text}
    end
  end

  def unsubscribe
    response = Payment.unsubscribe current_user
    if response.success?
      # current_user.subscription.delete
      subscription = current_user.subscription
      subscription.canceled_at = Time.current
      subscription.save!
      current_user.subscription = nil
      current_user.free!
      NotificationMailer.delay.unsubscription(current_user.id, subscription.id)
      NotificationMailer.delay.unsubscription_to_admins(current_user.id, subscription.id)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  private

  def cc_expiration_date
    month, year = @expiration[0..1], @expiration[2..3]
    Date.new(('20'+year).to_i, month.to_i) rescue nil
  end

  def prevalidate
    @cart_num = params[:card_num]
    @customer = params[:customer].split(' ')
    @cvv = params[:cvv]
    @expiration = params[:month].to_s + params[:year].to_s

    unless cc_expiration_date
      render json: {error: 'Card expiration date is invalid'}, :status => 500
      return
    end

    if Date.today > cc_expiration_date
      render json: {error: 'Card has expired'}, :status => 500
      return
    end

    if params[:coupon] && params[:coupon] != 'false'
      @coupon = Coupon.find_by(code: params[:coupon])
      if @coupon
        @plan = @coupon.premium_plan
      else
        render json: {error: 'coupon not found'}, :status => 500
      end
    else
      @coupon = false
      @plan = PremiumPlan.find(params[:premium_plan].to_i)  if is_numeric? params[:premium_plan]
    end
  end

  def is_xhr
    redirect_to :root unless request.xhr?
  end

  def is_numeric?(x)
    true if Float(x) rescue false
  end

end




