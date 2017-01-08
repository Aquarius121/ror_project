class GpxExporter

  def self.export(route)
    data = ActiveSupport::JSON.decode(route.data)
    return nil unless data

    points = data['route_data']
    waypoints = [data['origin'], data['waypoints'], data['destination']].flatten

    return nil if waypoints.length < 2

    xml_namespace = {
        creator: "RidingSocial https://maps/ridingsocial.com/",
        version: '1.1',
        :xmlns => 'http://www.topografix.com/GPX/1/1',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation' => 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd'
    }

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.gpx(xml_namespace) do
        xml.metadata do
          xml.name route.title
          xml.author do
            xml.name route.user.full_name
          end
          xml.link href: "https://maps/ridingsocial.com/embed/#{route.id}"
        end
        waypoints.each do |wp|
          xml.wpt(lat: wp['latitude'].round(5), lon: wp['longitude'].round(5)) do
            xml.name wp['location']
          end
        end
        if points && points.length > 0
          xml.trk do
            xml.name route.title
            xml.link href: "https://maps/ridingsocial.com/embed/#{route.id}"
            xml.type "Ride"
            xml.trkseg do
              points.each do |point|
                xml.trkpt(lat: point[0].round(5), lon: point[1].round(5))
              end
            end
          end
        end
      end
    end
    builder.to_xml
  end

end