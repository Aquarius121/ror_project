require 'apn_connection'

class NotifierWorker
  include Sidekiq::Worker

  APN_POOL = ConnectionPool.new(:size => 1, :timeout => 300) do
    APNConnection.new
  end

  def perform(recipient_ids, message, custom_data = nil)
    recipient_ids = Array(recipient_ids)

    APN_POOL.with do |connection|

      tokens = User.where(id: recipient_ids).pluck(:device_tokens).flatten.compact

      tokens.each do |token|
        notification = Houston::Notification.new(device: token)
        notification.alert = message
        notification.sound = 'default'
        notification.custom_data = custom_data
        connection.write(notification.message)
        ssl = connection.ssl

        read_socket, write_socket = IO.select([ssl], [], [ssl], 0.1)
        if (read_socket && read_socket[0])
          if error = connection.read(6)
            command, status, index = error.unpack("ccN")
            notification.apns_error_code = status
            notification.mark_as_unsent!
          end
        end

        if notification.error
          Rails.logger.error "Error: #{notification.error}."
          connection.setup if notification.error.code == 8
        end
      end
    end
  end

end