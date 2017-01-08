require 'gpx/base_processor'

module Gpx

  class TrackptProcessor < BaseProcessor

    def initialize(gpx, user_id)
      super
      @min_time = DateTime.now
      @max_time = 100.years.ago
    end

    def extract_data(node, route_points, points)
      if @waypoints && @waypoints.length > 1
        #try to get waypoints based on this track first/last points
        origin = @waypoints.find { |wp| same_latlng?(route_points.first, wp) }
        destination = @waypoints.find { |wp| same_latlng?(route_points.last, wp) }
      end
      origin ||= point_to_waypoint(points.first)
      destination ||= point_to_waypoint(points.last)
      duration = (@max_time.to_i - @min_time.to_i) > 0 ? @max_time.to_i - @min_time.to_i : nil
      [origin, destination, duration, nil]
    end

    def process
      @saved_tracks_count = 0
      save_tracks

      if @saved_tracks_count == 0
        # lets save waypoints as google directions track
        save_route(@doc.root, [], [])
      elsif @saved_tracks_count > 1
        # lets save all tracks as one
        save_all_tracks_as_one
      end
    end

    private

    def save_tracks
      @doc.root.elements.each do |node|
        if node.node_name.eql? 'wpt'
          @waypoints << {
              latitude: node['lat'],
              longitude: node['lon'],
              location: node.at_css('name').text
          }
        end

        if node.node_name.eql? 'trk'
          points = []
          @min_time = DateTime.now
          @max_time = 100.years.ago

          node.elements.each do |seg_node|
            if seg_node.node_name.eql? 'trkseg'
              seg_node.elements.each do |p|
                if p.at_css('ele')
                  points << [p['lat'], p['lon'], p.at_css('ele').text]
                else
                  points << [p['lat'], p['lon']]
                end
                if p.at_css('time')
                  point_time = DateTime.parse(p.at_css('time').text)
                  @max_time = point_time if point_time > @max_time
                  @min_time = point_time if point_time < @min_time
                end
              end
            end
          end
          points = points.map do |point|
            #point = [lat, lng, ele(optional)]
            point.map { |l| remove_float_artefacts(l) }
          end
          save_route(node, node.css('trkpt'), points)
          @saved_tracks_count += 1
        end
      end
    end

    def save_all_tracks_as_one
      last_node = nil
      points = []
      route_points = []
      @min_time = DateTime.now
      @max_time = 100.years.ago

      @doc.root.elements.each do |node|
        if node.node_name.eql?('trk') && node.at_css('name') && !(node.at_css('name').text =~ /ALT/)
          node.elements.each do |seg_node|
            if seg_node.node_name.eql? 'trkseg'
              seg_node.elements.each do |p|
                if p.at_css('ele')
                  points << [p['lat'], p['lon'], p.at_css('ele').text]
                else
                  points << [p['lat'], p['lon']]
                end
                if p.at_css('time')
                  point_time = DateTime.parse(p.at_css('time').text)
                  @max_time = point_time if point_time > @max_time
                  @min_time = point_time if point_time < @min_time
                end
              end
            end
          end
          points = points.map { |point| point.map { |l| remove_float_artefacts(l) } }

          last_node = node
          route_points += node.css('trkpt')
        end
      end
      save_route(last_node, route_points, points) if last_node
    end


    def remove_float_artefacts(float_string)
      float_string.sub(/0{6,10}\d$/, '')
    end

    def point_to_waypoint(point)
      {
          latitude: point[0],
          longitude: point[1],
          location: ''
      }
    end
  end
end