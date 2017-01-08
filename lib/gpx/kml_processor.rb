module Gpx

  class KmlProcessor < BaseProcessor

    def extract_data(node, route_points, points)
      begin
        origin = to_data_node(route_points.first)
        destination = to_data_node(route_points.last)
      rescue
        if @waypoints.length > 1
          origin = @waypoints.first
          destination = @waypoints.last
        else
          origin = point_to_waypoint(points.first, 'Start')
          destination = point_to_waypoint(points.last, 'End')
        end
      end

      [origin, destination, nil, nil]
    end


    def process
      use_folders = @doc.css('Folder').length > 1
      points, node, route_points = use_folders ? with_folders : without_folders
      save_route(node, route_points, points)
    end

    private

    def with_folders
      points = node = route_points = nil
      @doc.css('Document > Folder').each do |folder|
        name = folder.at_css('name').text.downcase
        if name == 'routes'
          folder.css('Folder').each do |sub_folder|
            name = sub_folder.at_css('name').text.downcase
            if name == 'paths'
              points = parse_path(sub_folder)
              node = sub_folder.at_css('Placemark')
            end
            if name == 'via points'
              @waypoints = parse_waypoints(sub_folder)
              route_points = sub_folder.css('Placemark')
            end
          end
        end
        if name == 'tracks'
          folder.css('>Folder').each do |sub_folder|
            route_points = []
            points = parse_path(sub_folder)
            node = sub_folder
          end
        end
      end
      [points, node, route_points]
    end

    def without_folders
      node = nil
      route_points = []
      points = nil

      node = @doc.at_css('Document')
      @doc.css('Placemark').each do |place|
        name = place.at_css('name').text.downcase
        if %w(from: to:).any? { |waypoint_marker| name.include? waypoint_marker }
          data_node = to_data_node(place)
          data_node[:location] = data_node[:location].sub('From: ', '').sub('To: ', '')
          @waypoints << data_node
          route_points << place
        else
          path = parse_path(place)
          points = !points ? path : points + path
        end
      end

      [points, node, route_points]
    end

    def parse_waypoints(folder)
      folder.css('Placemark').map { |placemark| to_data_node(placemark) }
    end

    def parse_path(node)
      path = node.at_css('LineString coordinates').text
      path.split(/\s/).reject { |s| s.empty? }.map do |coordinate|
        (lon, lat, elevation) = coordinate.split(',')
        [lat, lon, elevation]
      end
    end

    def to_data_node(place_mark)
      point = place_mark.at_css('Point coordinates').text.split(',').first 2
      {
          location: place_mark.at_css('name').text,
          longitude: point.first,
          latitude: point.last
      }
    end

    def point_to_waypoint(point, location = '')
      {
          latitude: point[0],
          longitude: point[1],
          location: location
      }
    end

  end
end

