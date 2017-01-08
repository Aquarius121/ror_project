if defined?(Airbrake)
  Airbrake.configure do |config|
    config.api_key = '6d0cd7f1e770795487103c9387949838'
    config.params_filters << 'card_num'
    config.params_filters << 'card-num'
    config.params_filters << 'cvv'
    config.params_filters << 'customer'
  end
end
