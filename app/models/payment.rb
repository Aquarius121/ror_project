require 'authorize_net'
class Payment

  def self.subscribe(plan, cart_num, expiration, cvv, current_user, customer_name, coupon = false)
    if coupon
      price = self.percent_of(plan.price, coupon.discount).to_i
    else
      price = plan.price
    end
    cc = AuthorizeNet::CreditCard.new(cart_num, expiration, {card_code: cvv})
    first_payment = AuthorizeNet::AIM::Transaction.new(*credentials)
    first_payment.set_fields({email: current_user.email})
    response = first_payment.authorize(1.0, cc)
    Rails.logger.info "first_payment.response.success?: #{response.success?}"
    Rails.logger.info "first_payment.response.response_reason_text: #{response.response_reason_text}"

    if response.success?
      void_payment = AuthorizeNet::AIM::Transaction.new(*credentials)
      void_payment.void(response.transaction_id)

      transaction = AuthorizeNet::ARB::Transaction.new(*credentials)
      subscription = AuthorizeNet::ARB::Subscription.new(
          :name => plan.name,
          :length => plan.period,
          :unit => :month,
          :start_date => Date.today,
          :total_occurrences => AuthorizeNet::ARB::Subscription::UNLIMITED_OCCURRENCES,
          :amount => price,
          :customer => AuthorizeNet::Customer.new(:email => current_user.email, :id => current_user.id),
          :description => plan.description,
          :credit_card => cc,
          :billing_address => AuthorizeNet::Address.new(:first_name => customer_name.first, :last_name => customer_name.last)
      )
      [response, transaction.create(subscription)]
    else
      [response, nil]
    end
  end

  def self.unsubscribe(current_user)
    transaction = AuthorizeNet::ARB::Transaction.new(*credentials)
    transaction.cancel(current_user.subscription.transaction_id)
  end

  def self.update_subscription(cart_num, expiration, cvv, current_user, customer_name)
    cc = AuthorizeNet::CreditCard.new(cart_num, expiration, {card_code: cvv})
    billing_address = AuthorizeNet::Address.new(:first_name => customer_name.first, :last_name => customer_name.last)
    transaction = AuthorizeNet::ARB::Transaction.new(*credentials)
    subscription = AuthorizeNet::ARB::Subscription.new(
        :credit_card => cc,
        :billing_address => billing_address,
        :subscription_id => current_user.subscription.transaction_id
    )
    transaction.update(subscription)
  end

  def self.check_subscription_status(subscription_id)
    transaction = AuthorizeNet::ARB::Transaction.new(*credentials)
    transaction.get_status(subscription_id)
  end

  def self.transaction_details(transaction_id)
    transaction = AuthorizeNet::Reporting::Transaction.new(*credentials)
    response = transaction.get_transaction_details(transaction_id)
    response.transaction
  end

  def self.percent_of(price, discount)
   price.to_f - ( discount.to_f * ( price.to_f / 100.0))
  end

  def self.get_inactive_subscriptions
    sorting = AuthorizeNet::ARB::Sorting.new('name', true)
    paging = AuthorizeNet::ARB::Paging.new(1, 1000)
    transaction = AuthorizeNet::ARB::Transaction.new(*credentials)
    response = transaction.get_subscription_list('subscriptionInactive', sorting, paging)
    response.subscription_details
  end

  def self.credentials
    [AUTHORIZE_NET_CONFIG["api_login_id"], AUTHORIZE_NET_CONFIG["api_transaction_key"], :gateway => Rails.env.development? ? :test : :live]
  end

end

