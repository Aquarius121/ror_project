# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140730124240) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "postgis_topology"
  enable_extension "fuzzystrmatch"
  enable_extension "postgis_tiger_geocoder"

  create_table "activities", force: true do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.date     "activity_date"
    t.text     "activity_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["follower_id"], name: "index_activities_on_follower_id", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "addr", primary_key: "gid", force: true do |t|
    t.integer "tlid",      limit: 8
    t.string  "fromhn",    limit: 12
    t.string  "tohn",      limit: 12
    t.string  "side",      limit: 1
    t.string  "zip",       limit: 5
    t.string  "plus4",     limit: 4
    t.string  "fromtyp",   limit: 1
    t.string  "totyp",     limit: 1
    t.integer "fromarmid"
    t.integer "toarmid"
    t.string  "arid",      limit: 22
    t.string  "mtfcc",     limit: 5
    t.string  "statefp",   limit: 2
  end

  add_index "addr", ["tlid", "statefp"], name: "idx_tiger_addr_tlid_statefp", using: :btree
  add_index "addr", ["zip"], name: "idx_tiger_addr_zip", using: :btree

# Could not dump table "addrfeat" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "affiliates", force: true do |t|
    t.integer  "club_id"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "start"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "affiliates", ["club_id"], name: "index_affiliates_on_club_id", using: :btree
  add_index "affiliates", ["user_id"], name: "index_affiliates_on_user_id", using: :btree

  create_table "announcements", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "club_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "announcements", ["club_id"], name: "index_announcements_on_club_id", using: :btree

  create_table "attachments", force: true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gallery_id"
  end

  add_index "attachments", ["gallery_id"], name: "index_attachments_on_gallery_id", using: :btree

# Could not dump table "bg" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "card_transactions", force: true do |t|
    t.string   "raw_data",     limit: 4096
    t.datetime "processed_at"
  end

  create_table "club_types", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clubs", force: true do |t|
    t.string   "title"
    t.string   "logo"
    t.text     "description"
    t.string   "location"
    t.integer  "privacy_id"
    t.integer  "ClubType_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "logo_id"
  end

  add_index "clubs", ["ClubType_id"], name: "index_clubs_on_ClubType_id", using: :btree
  add_index "clubs", ["privacy_id"], name: "index_clubs_on_privacy_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "related_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["related_id"], name: "index_comments_on_related_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "conditions", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "county" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "county_lookup", id: false, force: true do |t|
    t.integer "st_code",            null: false
    t.string  "state",   limit: 2
    t.integer "co_code",            null: false
    t.string  "name",    limit: 90
  end

  add_index "county_lookup", ["state"], name: "county_lookup_state_idx", using: :btree

  create_table "countysub_lookup", id: false, force: true do |t|
    t.integer "st_code",            null: false
    t.string  "state",   limit: 2
    t.integer "co_code",            null: false
    t.string  "county",  limit: 90
    t.integer "cs_code",            null: false
    t.string  "name",    limit: 90
  end

  add_index "countysub_lookup", ["state"], name: "countysub_lookup_state_idx", using: :btree

  create_table "coupons", force: true do |t|
    t.integer  "premium_plan_id"
    t.string   "code"
    t.integer  "discount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

# Could not dump table "cousub" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "direction_lookup", id: false, force: true do |t|
    t.string "name",   limit: 20, null: false
    t.string "abbrev", limit: 3
  end

  add_index "direction_lookup", ["abbrev"], name: "direction_lookup_abbrev_idx", using: :btree

# Could not dump table "edges" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "faces" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "featnames", primary_key: "gid", force: true do |t|
    t.integer "tlid",       limit: 8
    t.string  "fullname",   limit: 100
    t.string  "name",       limit: 100
    t.string  "predirabrv", limit: 15
    t.string  "pretypabrv", limit: 50
    t.string  "prequalabr", limit: 15
    t.string  "sufdirabrv", limit: 15
    t.string  "suftypabrv", limit: 50
    t.string  "sufqualabr", limit: 15
    t.string  "predir",     limit: 2
    t.string  "pretyp",     limit: 3
    t.string  "prequal",    limit: 2
    t.string  "sufdir",     limit: 2
    t.string  "suftyp",     limit: 3
    t.string  "sufqual",    limit: 2
    t.string  "linearid",   limit: 22
    t.string  "mtfcc",      limit: 5
    t.string  "paflag",     limit: 1
    t.string  "statefp",    limit: 2
  end

  add_index "featnames", ["tlid", "statefp"], name: "idx_tiger_featnames_tlid_statefp", using: :btree

  create_table "friendships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "galleries", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "route_id"
  end

  add_index "galleries", ["route_id"], name: "index_galleries_on_route_id", using: :btree

  create_table "galleries_attachments", force: true do |t|
    t.integer  "gallery_id"
    t.integer  "attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "galleries_attachments", ["attachment_id"], name: "index_galleries_attachments_on_attachment_id", using: :btree
  add_index "galleries_attachments", ["gallery_id"], name: "index_galleries_attachments_on_gallery_id", using: :btree

  create_table "geocode_settings", id: false, force: true do |t|
    t.text "name",       null: false
    t.text "setting"
    t.text "unit"
    t.text "category"
    t.text "short_desc"
  end

  create_table "invites", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loader_lookuptables", id: false, force: true do |t|
    t.integer "process_order",                   default: 1000,  null: false
    t.text    "lookup_name",                                     null: false
    t.text    "table_name"
    t.boolean "single_mode",                     default: true,  null: false
    t.boolean "load",                            default: true,  null: false
    t.boolean "level_county",                    default: false, null: false
    t.boolean "level_state",                     default: false, null: false
    t.boolean "level_nation",                    default: false, null: false
    t.text    "post_load_process"
    t.boolean "single_geom_mode",                default: false
    t.string  "insert_mode",           limit: 1, default: "c",   null: false
    t.text    "pre_load_process"
    t.text    "columns_exclude",                                              array: true
    t.text    "website_root_override"
  end

  create_table "loader_platform", id: false, force: true do |t|
    t.string "os",                     limit: 50, null: false
    t.text   "declare_sect"
    t.text   "pgbin"
    t.text   "wget"
    t.text   "unzip_command"
    t.text   "psql"
    t.text   "path_sep"
    t.text   "loader"
    t.text   "environ_set_command"
    t.text   "county_process_command"
  end

  create_table "loader_variables", id: false, force: true do |t|
    t.string "tiger_year",     limit: 4, null: false
    t.text   "website_root"
    t.text   "staging_fold"
    t.text   "data_schema"
    t.text   "staging_schema"
  end

  create_table "members", force: true do |t|
    t.integer  "club_id"
    t.integer  "user_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["club_id"], name: "index_members_on_club_id", using: :btree
  add_index "members", ["user_id"], name: "index_members_on_user_id", using: :btree

  create_table "pagc_gaz", force: true do |t|
    t.integer "seq"
    t.text    "word"
    t.text    "stdword"
    t.integer "token"
    t.boolean "is_custom", default: true, null: false
  end

  create_table "pagc_lex", force: true do |t|
    t.integer "seq"
    t.text    "word"
    t.text    "stdword"
    t.integer "token"
    t.boolean "is_custom", default: true, null: false
  end

  create_table "pagc_rules", force: true do |t|
    t.text    "rule"
    t.boolean "is_custom", default: true
  end

# Could not dump table "place" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "place_lookup", id: false, force: true do |t|
    t.integer "st_code",            null: false
    t.string  "state",   limit: 2
    t.integer "pl_code",            null: false
    t.string  "name",    limit: 90
  end

  add_index "place_lookup", ["state"], name: "place_lookup_state_idx", using: :btree

  create_table "premium_plans", force: true do |t|
    t.string   "name"
    t.float    "price"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "period"
    t.string   "label"
    t.boolean  "archived",    default: false, null: false
  end

  create_table "privacies", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referrals", force: true do |t|
    t.integer  "user_id"
    t.integer  "referral_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ride_types", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "riding_preferences", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "routes", force: true do |t|
    t.string   "title"
    t.string   "difficulty"
    t.float    "rating"
    t.string   "elevation"
    t.date     "ridedate"
    t.text     "description"
    t.integer  "privacy_id"
    t.integer  "condition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data"
    t.integer  "user_id"
    t.integer  "surface_id"
    t.integer  "ride_distance"
    t.integer  "ride_time"
    t.boolean  "completed",                  default: false
    t.integer  "ridetype_id"
    t.string   "encoded_path",  limit: 4096
    t.boolean  "is_readonly",                default: false
  end

  add_index "routes", ["condition_id"], name: "index_routes_on_condition_id", using: :btree
  add_index "routes", ["privacy_id"], name: "index_routes_on_privacy_id", using: :btree
  add_index "routes", ["ridetype_id"], name: "index_routes_on_ridetype_id", using: :btree
  add_index "routes", ["surface_id"], name: "index_routes_on_surface_id", using: :btree
  add_index "routes", ["user_id"], name: "index_routes_on_user_id", using: :btree

  create_table "secondary_unit_lookup", id: false, force: true do |t|
    t.string "name",   limit: 20, null: false
    t.string "abbrev", limit: 5
  end

  add_index "secondary_unit_lookup", ["abbrev"], name: "secondary_unit_lookup_abbrev_idx", using: :btree

  create_table "shared_rides", force: true do |t|
    t.integer  "route_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "new"
  end

  create_table "spatial_ref_sys", id: false, force: true do |t|
    t.integer "srid",                   null: false
    t.string  "auth_name", limit: 256
    t.integer "auth_srid"
    t.string  "srtext",    limit: 2048
    t.string  "proj4text", limit: 2048
  end

# Could not dump table "state" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "state_lookup", id: false, force: true do |t|
    t.integer "st_code",            null: false
    t.string  "name",    limit: 40
    t.string  "abbrev",  limit: 3
    t.string  "statefp", limit: 2
  end

  add_index "state_lookup", ["abbrev"], name: "state_lookup_abbrev_key", unique: true, using: :btree
  add_index "state_lookup", ["name"], name: "state_lookup_name_key", unique: true, using: :btree
  add_index "state_lookup", ["statefp"], name: "state_lookup_statefp_key", unique: true, using: :btree

  create_table "street_type_lookup", id: false, force: true do |t|
    t.string  "name",   limit: 50,                 null: false
    t.string  "abbrev", limit: 50
    t.boolean "is_hw",             default: false, null: false
  end

  add_index "street_type_lookup", ["abbrev"], name: "street_type_lookup_abbrev_idx", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "transaction_id"
    t.integer  "premium_plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "card_expires_at"
    t.boolean  "email_sent"
    t.integer  "coupon_id"
  end

  create_table "surfaces", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "tabblock" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "tract" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "user_bikes", force: true do |t|
    t.integer  "user_id"
    t.string   "model"
    t.integer  "type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_bikes", ["user_id"], name: "index_user_bikes_on_user_id", using: :btree

  create_table "user_riding_preferences", force: true do |t|
    t.integer  "user_id"
    t.integer  "preference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                                                      default: "", null: false
    t.string   "encrypted_password",                                         default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                              default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "zip"
    t.string   "motorcycle_club"
    t.integer  "fb_id",                  limit: 8
    t.string   "fb_token",               limit: nil
    t.string   "location"
    t.string   "gender"
    t.string   "age"
    t.text     "about_me"
    t.string   "riding_preference"
    t.boolean  "subscribed"
    t.integer  "avatar_id"
    t.string   "authentication_token"
    t.integer  "subscription_id"
    t.integer  "fb_friends_ids",                                             default: [],              array: true
    t.datetime "fb_fetched_at"
    t.decimal  "latitude",                           precision: 9, scale: 6
    t.decimal  "longitude",                          precision: 9, scale: 6
  end

  add_index "users", ["avatar_id"], name: "index_users_on_avatar_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

# Could not dump table "zcta5" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "zip_lookup", id: false, force: true do |t|
    t.integer "zip",                null: false
    t.integer "st_code"
    t.string  "state",   limit: 2
    t.integer "co_code"
    t.string  "county",  limit: 90
    t.integer "cs_code"
    t.string  "cousub",  limit: 90
    t.integer "pl_code"
    t.string  "place",   limit: 90
    t.integer "cnt"
  end

  create_table "zip_lookup_all", id: false, force: true do |t|
    t.integer "zip"
    t.integer "st_code"
    t.string  "state",   limit: 2
    t.integer "co_code"
    t.string  "county",  limit: 90
    t.integer "cs_code"
    t.string  "cousub",  limit: 90
    t.integer "pl_code"
    t.string  "place",   limit: 90
    t.integer "cnt"
  end

  create_table "zip_lookup_base", id: false, force: true do |t|
    t.string "zip",     limit: 5,  null: false
    t.string "state",   limit: 40
    t.string "county",  limit: 90
    t.string "city",    limit: 90
    t.string "statefp", limit: 2
  end

  create_table "zip_state", id: false, force: true do |t|
    t.string "zip",     limit: 5, null: false
    t.string "stusps",  limit: 2, null: false
    t.string "statefp", limit: 2
  end

  create_table "zip_state_loc", id: false, force: true do |t|
    t.string "zip",     limit: 5,   null: false
    t.string "stusps",  limit: 2,   null: false
    t.string "statefp", limit: 2
    t.string "place",   limit: 100, null: false
  end

end
