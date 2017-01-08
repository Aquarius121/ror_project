# == Schema Information
#
# Table name: card_transactions
#
#  id           :integer          not null, primary key
#  raw_data     :string(4096)
#  processed_at :datetime
#

class CardTransaction < ActiveRecord::Base
  scope :waiting, -> { where(:processed_at => nil) }
  scope :processed, -> { where.not(:processed_at => nil) }


  def notify_about_cc_operation
    return if self.processed_at
    transaction = AuthorizeNet::SIM::Response.new(self.raw_data)
    # only ARB transactions have subscription id
    subscription_id = transaction.custom_fields[:x_subscription_id]
    subscription = subscription_id && Subscription.find_by(:transaction_id => subscription_id)
    if subscription
      amount = transaction.fields[:amount]
      response_code = transaction.fields[:response_code]
      description = case response_code
                      when '1'
                        'approved'
                      when '2'
                        'declined'
                      when '3'
                        'couldn\'t be processed because the card has expired'
                      when '4'
                        'held for review'
                      else
                        'unknown reason code'
                    end
      reason = transaction.fields[:response_reason_text]
      # we must return the user his PRO acc if there was successful payment
      subscription.user.premium! if response_code == '1'
      NotificationMailer.cc_operation(subscription.user.id, amount, description, reason).deliver
    end
    self.processed_at = DateTime.now
    self.save!
  end
end
