module DashboardHelper

  def dashboard_right_saved_rides
    render 'template/dashboard/right/rides',
           :ride_stats => get_rides_stats_uncompleted, :title => 'Saved rides'
  end

  def name_or_email
    if current_user.firstname? && current_user.lastname?
      return current_user.full_name
    else
      return current_user.email.to_s
    end
  end

  def dashboard_single_ride(date, title, distance, id)
    render 'template/dashboard/left/single_ride',
           :date => date, :title => title, :distance => distance, :id => id
  end


  def user_activities
    Activity.for_user(current_user)
  end

  def user_routes
    Route.where(user_id: current_user.id).reorder(created_at: :desc).limit(3)
  end

  def meters_to_mile(meters = 0)
    UnitsConverter.meters_to_mile(meters)
  end

  def meters_to_feet(meters = 0)
    UnitsConverter.meters_to_feet(meters)
  end

  def seconds_to_screen(sec = 0)
    UnitsConverter.seconds_to_screen(sec)
  end

  def seconds_to_time(sec = 0)
    UnitsConverter.seconds_to_time(sec)
  end

  def seconds_to_time_short(sec = 0)
    UnitsConverter.seconds_to_time_short(sec)
  end

  def get_rides_stats
    @get_rides_stats ||= Route.select('count(*) as count, sum(ride_distance) as distance, sum(ride_time) as time').
        joins('LEFT JOIN "shared_rides" ON "shared_rides"."route_id" = "routes"."id"').
        where('"routes"."user_id" = ? OR "shared_rides"."user_id" = ?', current_user.id, current_user.id).to_a.first
  end

  def get_rides_stats_completed
    @get_rides_stats_completed ||= Route.select('count(*) as count, sum(ride_distance) as distance, sum(ride_time) as time').where(user_id: current_user.id, completed: true).to_a.first
  end

  def get_rides_stats_uncompleted
    @get_rides_stats_uncompleted ||= Route.select('count(*) as count, sum(ride_distance) as distance, sum(ride_time) as time').where(user_id: current_user.id, completed: false).to_a.first
  end

  def get_rides_stats_week
    time_range = Time.now - 1.week
    times = time_range.strftime('%Y-%m-%d')
    Route.select('count(*) as count, sum(ride_distance) as distance, sum(ride_time) as time').where('user_id = ? AND completed = true AND ridedate >= ?', current_user.id, times).to_a.first
  end

  def get_last_ride_title
    @get_last_ride_title ||= Route.where(user_id: current_user.id).limit(1).order(updated_at: :desc).pluck(:title)
  end

end