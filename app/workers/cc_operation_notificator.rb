class CCOperationNotificator
  include Sidekiq::Worker

  def perform(card_transaction_id)
    operation = CardTransaction.find card_transaction_id
    operation.notify_about_cc_operation
  end
end