require 'layer_import'

class LayerImporter
  include Sidekiq::Worker

  def perform(map_id)
    response = LayerImport.new.work(map_id)
    raise StandardError if response && response.status != 200
  end
end
