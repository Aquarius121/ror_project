class ChangeDataTypeToText < ActiveRecord::Migration
  def change
    execute ('ALTER TABLE "routes" ALTER COLUMN "data" TYPE text USING data::text;')
  end
end
