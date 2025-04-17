# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_17_063135) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "airports", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.bigint "state_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icao_code"
    t.bigint "city_id", null: false
    t.text "description"
    t.index ["city_id"], name: "index_airports_on_city_id"
    t.index ["code"], name: "index_airports_on_code", unique: true
    t.index ["icao_code"], name: "index_airports_on_icao_code", unique: true
    t.index ["state_id"], name: "index_airports_on_state_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "state_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id", "name"], name: "index_cities_on_state_id_and_name", unique: true
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "contact_people", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "phone"
    t.string "email"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_contact_people_on_school_id"
  end

  create_table "nearby_cities", force: :cascade do |t|
    t.bigint "city_id", null: false
    t.bigint "nearby_city_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id", "nearby_city_id"], name: "index_nearby_cities_on_city_id_and_nearby_city_id", unique: true
    t.index ["city_id"], name: "index_nearby_cities_on_city_id"
    t.index ["nearby_city_id"], name: "index_nearby_cities_on_nearby_city_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.decimal "rating", precision: 3, scale: 1, null: false
    t.text "comment", null: false
    t.string "reviewer_name"
    t.string "reviewer_email"
    t.bigint "user_id"
    t.bigint "school_id", null: false
    t.boolean "published", default: true
    t.boolean "verified", default: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_reviews_on_school_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "website"
    t.string "phone"
    t.bigint "airport_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "est_planes"
    t.integer "est_cfis"
    t.boolean "part_141", default: false, null: false
    t.boolean "part_61", default: false, null: false
    t.string "training_types", default: [], null: false, array: true
    t.boolean "accelerated_programs", default: false, null: false
    t.boolean "examining_authority", default: false, null: false
    t.date "date_established"
    t.boolean "featured", default: false, null: false
    t.boolean "approved", default: true, null: false
    t.decimal "avg_rating", precision: 3, scale: 1
    t.index ["airport_id", "name"], name: "index_schools_on_airport_id_and_name", unique: true
    t.index ["airport_id"], name: "index_schools_on_airport_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abbreviation"], name: "index_states_on_abbreviation", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.string "name"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "airports", "cities"
  add_foreign_key "airports", "states"
  add_foreign_key "cities", "states"
  add_foreign_key "contact_people", "schools"
  add_foreign_key "nearby_cities", "cities"
  add_foreign_key "nearby_cities", "cities", column: "nearby_city_id"
  add_foreign_key "reviews", "schools"
  add_foreign_key "reviews", "users"
  add_foreign_key "schools", "airports"
end
