require 'gpx/garmin_xx_processor'
require 'gpx/trackpt_processor'
require 'gpx/kml_processor'

module Gpx

  class ImportFactory

    def self.processor_for(file)
      doc = Nokogiri::XML(file)
      file.rewind
      return GarminXXProcessor if is_garmin?(doc)
      return KmlProcessor if is_kml?(doc)
      TrackptProcessor
    end

    private

    def self.is_garmin?(doc)
      doc.namespaces["xmlns:gpxx"] &&
          (doc.css('gpxx|rpt').count > 0 || doc.css('rtept').count > 0)
    end

    def self.is_kml?(doc)
      doc.root.node_name == 'kml'
    end

  end

end