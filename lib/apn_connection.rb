require 'forwardable'
class APNConnection
  extend Forwardable
  def_delegators :@connection, :ssl, :read

  def initialize
    setup
  end

  def setup
    @uri = Rails.env.production? ?
        Houston::APPLE_PRODUCTION_GATEWAY_URI :
        Houston::APPLE_DEVELOPMENT_GATEWAY_URI

    env = Rails.env.production? ? Rails.env : 'development'
    @certificate = File.read("#{Rails.root}/config/certs/apn_#{env}.pem")
    @connection = Houston::Connection.new(@uri, @certificate, 'asfdasfd')
    @connection.open
  end

  def write(data)
    begin
      raise 'Connection is closed' unless @connection.open?
      @connection.write(data)
    rescue Exception => e
      attempts ||= 0
      attempts += 1

      if attempts < 5
        setup
        retry
      else
        raise e
      end
    end
  end

end
