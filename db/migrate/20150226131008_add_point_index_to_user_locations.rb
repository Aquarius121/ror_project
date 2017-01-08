class AddPointIndexToUserLocations < ActiveRecord::Migration
  def up
    execute %{
      create index index_on_users_locations_location ON user_locations using gist (
        ST_GeographyFromText(
          'SRID=4326;POINT(' || user_locations.longitude || ' ' || user_locations.latitude || ')'
        )
      )
    }
  end

  def down
    execute 'drop index index_on_users_locations_location'
  end
end
