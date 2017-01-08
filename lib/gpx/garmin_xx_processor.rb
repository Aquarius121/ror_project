require 'gpx/base_processor'

module Gpx
  class GarminXXProcessor < BaseProcessor

    def extract_data(node, route_points, points)
      origin = route_points.shift
      destination = route_points.pop
      origin = {location: origin.at_css('name').text, latitude: origin['lat'], longitude: origin['lon']}
      destination = {location: destination.at_css('name').text, latitude: destination['lat'], longitude: destination['lon']}
      timestamps = route_points.map { |point| DateTime.parse(point.at_css('time')) }
      duration = timestamps.max.to_i - timestamps.min.to_i
      [origin, destination, duration > 6*3600 ? nil : duration]
    end

    def process
      @doc.root.elements.each do |node|
        if node.node_name.eql? 'wpt'
          @waypoints << {
              latitude: node['lat'],
              longitude: node['lon'],
              location: node.at_css('name').text
          }
        end
        if node.node_name.eql? 'rte'
          points = []
          node.elements.each do |route_node|
            if route_node.node_name.eql? 'rtept'
              if route_node.at_css('extensions')
                route_node.css('gpxx|rpt').each do |p|
                  points << [p['lat'], p['lon']]
                end
              else
                points << [route_node['lat'], route_node['lon']]
              end
            end
          end
          @waypoints = @waypoints.sort_by { |wp| node.css('rtept').find_index {|p| same_latlng?(p, wp) }}

          save_route(node, node.css('rtept'), points)
        end
      end
    end

  end
end
