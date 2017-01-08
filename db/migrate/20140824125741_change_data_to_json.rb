class ChangeDataToJson < ActiveRecord::Migration
  def change
    execute ('ALTER TABLE "routes" ALTER COLUMN "data" TYPE json USING data::json;')
  end
end
