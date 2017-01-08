class AddMaxLeanToRoutes < ActiveRecord::Migration
  def change
    add_column(:routes, :max_lean, :integer)
  end
end
