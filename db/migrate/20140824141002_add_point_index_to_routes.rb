class AddPointIndexToRoutes < ActiveRecord::Migration
  def up
    execute %{
      create index index_on_routes_location ON routes using gist (
        ST_GeographyFromText(
          'SRID=4326;POINT(' || routes.longitude || ' ' || routes.latitude || ')'
        )
      )
    }
  end

  def down
    execute 'drop index index_on_routes_location'
    Benchmark
  end
end
