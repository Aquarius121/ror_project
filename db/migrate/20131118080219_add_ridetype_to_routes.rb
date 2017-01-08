class AddRidetypeToRoutes < ActiveRecord::Migration
  def change
    add_reference :routes, :ridetype, index: true
  end
end
