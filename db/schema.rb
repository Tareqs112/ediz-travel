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

ActiveRecord::Schema[8.1].define(version: 2026_09_06_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accommodations", force: :cascade do |t|
    t.string "accommodation_type", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.string "location"
    t.string "name", null: false
    t.text "short_description"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["accommodation_type"], name: "index_accommodations_on_accommodation_type"
    t.index ["active"], name: "index_accommodations_on_active"
    t.index ["slug"], name: "index_accommodations_on_slug", unique: true
  end

  create_table "accommodations_packages", id: false, force: :cascade do |t|
    t.bigint "accommodation_id", null: false
    t.bigint "package_id", null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "booking_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_name", null: false
    t.string "email", null: false
    t.text "notes"
    t.string "phone"
    t.string "preferred_language"
    t.string "status", default: "new", null: false
    t.bigint "tour_id", null: false
    t.date "travel_date", null: false
    t.integer "travelers_count", null: false
    t.datetime "updated_at", null: false
    t.index ["tour_id"], name: "index_booking_requests_on_tour_id"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.text "message"
    t.string "name"
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "destinations", force: :cascade do |t|
    t.boolean "active"
    t.string "best_time_to_visit"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "region"
    t.text "short_description"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_destinations_on_slug", unique: true
  end

  create_table "destinations_packages", id: false, force: :cascade do |t|
    t.bigint "destination_id", null: false
    t.bigint "package_id", null: false
  end

  create_table "packages", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "duration"
    t.string "excluded", default: [], array: true
    t.string "highlights", default: [], array: true
    t.string "included", default: [], array: true
    t.jsonb "itinerary", default: []
    t.text "short_description"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_packages_on_slug", unique: true
  end

  create_table "packages_tours", id: false, force: :cascade do |t|
    t.bigint "package_id", null: false
    t.bigint "tour_id", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tours", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "cancellation_policy"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.bigint "destination_id"
    t.string "duration"
    t.string "excluded", default: [], array: true
    t.string "group_size"
    t.string "highlights", default: [], array: true
    t.string "included", default: [], array: true
    t.jsonb "itinerary", default: []
    t.string "languages", default: [], array: true
    t.text "meeting_point"
    t.string "slug", null: false
    t.string "title", null: false
    t.string "tour_type"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tours_on_active"
    t.index ["destination_id"], name: "index_tours_on_destination_id"
    t.index ["slug"], name: "index_tours_on_slug", unique: true
  end

  create_table "travel_guides", force: :cascade do |t|
    t.boolean "active"
    t.text "content"
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.string "meta_description"
    t.datetime "published_at"
    t.string "slug"
    t.string "tags", default: [], array: true
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_travel_guides_on_active"
    t.index ["published_at"], name: "index_travel_guides_on_published_at"
    t.index ["slug"], name: "index_travel_guides_on_slug", unique: true
  end

  create_table "trip_inquiries", force: :cascade do |t|
    t.bigint "accommodation_id"
    t.datetime "created_at", null: false
    t.string "customer_name", null: false
    t.string "dropoff_location"
    t.integer "duration_days"
    t.string "email", null: false
    t.string "flight_details"
    t.string "inquiry_type", default: "general", null: false
    t.text "interests"
    t.text "notes"
    t.bigint "package_id"
    t.string "phone"
    t.string "pickup_location"
    t.string "pickup_time"
    t.string "preferred_language"
    t.string "status", default: "new", null: false
    t.date "travel_date", null: false
    t.integer "travelers_count", null: false
    t.datetime "updated_at", null: false
    t.string "vehicle_preference"
    t.index ["accommodation_id"], name: "index_trip_inquiries_on_accommodation_id"
    t.index ["package_id"], name: "index_trip_inquiries_on_package_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_requests", "tours"
  add_foreign_key "sessions", "users"
  add_foreign_key "tours", "destinations"
  add_foreign_key "trip_inquiries", "accommodations"
  add_foreign_key "trip_inquiries", "packages"
end
