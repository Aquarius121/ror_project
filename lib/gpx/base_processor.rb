module Gpx
  class BaseProcessor

    attr_reader :routes

    def self.process(gpx, user_id)
      import = self.new(gpx, user_id)
      import.process
      import.routes
    end

    def initialize(gpx, user_id)
      @doc = Nokogiri::XML(gpx)
      @waypoints = []
      @user_id = user_id
      @routes = []
    end

    def prepare_attribs(node, route_points, points)
      has_points = points && points.length > 0
      origin, destination, duration = extract_data(node, route_points, points)
      if route_points && route_points.length > 0
        begin
          waypoints = @waypoints.select do |wp|
            route_points.any? { |p| same_latlng?(p, wp) }
          end
        rescue
          waypoints = nil
        end
      else
        waypoints = @waypoints
      end

      waypoints = waypoints.reject do |wp|
        same_latlng_for_wpt?(wp, origin) || same_latlng_for_wpt?(wp, destination)
      end

      waypoints = waypoints.uniq { |wp| "#{wp[:latitude]}_#{wp[:longitude]}" }

      duration = nil if duration && duration > 12*60*60 #43200 - 12h in seconds

      ride_date = node.at_css('time').text rescue nil
      [origin, destination].each do |p|
        [:latitude, :longitude].each { |key| p[key] = p[key].to_f }
      end

      if has_points
        points = points.map { |p| p.map { |l| l.to_f } }
        ride_distance = calc_distance(points)
        elevation = calc_elevation(points)
        # remove elevation, as it is not needed on a map
        points = points.map { |p| p.first 2 }
      else
        ride_distance = 0
        elevation = 0
      end


      {
          title: node.at_css('name') ? node.at_css('name').text : "#{origin.location} to #{destination.location}",
          ridedate: ride_date || Time.now.strftime("%Y-%m-%d"),
          ride_time: duration || ride_distance / 30,
          ride_distance: ride_distance,
          elevation: elevation,
          user_id: @user_id,
          privacy_id: 1,
          is_readonly: true,
          completed: false,
          data: {
              origin: origin,
              route_type: has_points ? 'uploaded' : 'directions',
              destination: destination,
              waypoints: (waypoints || []).each { |p| [:latitude, :longitude].each { |key| p[key] = p[key].to_f } },
              route_data: points || []
          }.to_json
      }
    end

    def process
      #implement in subclasses
      raise 'Not Implemented'
    end


    def save_route(node, route_points, points)
      @routes << create_route(node, route_points, points)
    end

    def create_route(node, route_points, points)
      attributes = prepare_attribs(node, route_points, points)
      Route.create!(attributes)
    end

    def same_latlng?(point, waypoint)
      (point['lat'].to_f - waypoint[:latitude].to_f).abs < 0.001 && (point['lon'].to_f - waypoint[:longitude].to_f).abs < 0.001
    end

    def same_latlng_for_wpt?(wp1, wp2)
      (wp1[:latitude].to_f - wp2[:latitude].to_f).abs < 0.001 && (wp1[:longitude].to_f - wp2[:longitude].to_f).abs < 0.001
    end

    def calc_distance(points)
      current = points.shift
      points.inject(0) do |distance, point|
        v = Vincenty.new(current[0], current[1], current[2] || nil)
        c = Coordinate.new(point[0], point[1], point[2] || nil)
        delta = v.distanceAndAngle(c).distance
        distance += delta.nan? ? 0 : delta
        current = point
        distance
      end
    end

    def calc_elevation(points)
      current = points.first
      return nil if !current || current.length < 3
      points.inject(0) do |elevation, point|
        next elevation unless point[2] && current[2] # protect from nil
        delta = point[2] - current[2]
        elevation += delta if delta > 0
        current = point
        elevation
      end
    end

  end
end

