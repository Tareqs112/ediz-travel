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

ActiveRecord::Schema[8.1].define(version: 2026_09_11_181500) do
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

  create_table "bookings", force: :cascade do |t|
    t.bigint "booking_request_id"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.date "end_date"
    t.text "notes"
    t.string "source", default: "other", null: false
    t.date "start_date"
    t.string "status", default: "draft", null: false
    t.bigint "trip_inquiry_id"
    t.datetime "updated_at", null: false
    t.index ["booking_request_id"], name: "index_bookings_on_booking_request_id"
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
    t.index ["source"], name: "index_bookings_on_source"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["trip_inquiry_id"], name: "index_bookings_on_trip_inquiry_id"
  end

  create_table "business_settings", force: :cascade do |t|
    t.string "address"
    t.text "booking_policies"
    t.string "company_name"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.string "google_maps_url"
    t.boolean "singleton_guard", default: true, null: false
    t.string "tursab_number"
    t.datetime "updated_at", null: false
    t.string "whatsapp_number"
    t.index ["singleton_guard"], name: "index_business_settings_on_singleton_guard", unique: true
  end

  create_table "commercial_vehicles", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "currency"
    t.text "description"
    t.integer "luggage_capacity"
    t.string "name", null: false
    t.integer "passenger_capacity"
    t.decimal "price_from", precision: 10, scale: 2
    t.jsonb "translations", default: {}
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_commercial_vehicles_on_active"
    t.index ["category"], name: "index_commercial_vehicles_on_category"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.text "message"
    t.string "name"
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.string "preferred_language", default: "en"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email"
    t.index ["phone"], name: "index_customers_on_phone"
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

  create_table "drivers", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.string "phone", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_drivers_on_active"
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

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_batch_executions", force: :cascade do |t|
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.index ["batch_id"], name: "index_solid_queue_batch_executions_on_batch_id"
    t.index ["job_id"], name: "index_solid_queue_batch_executions_on_job_id", unique: true
  end

  create_table "solid_queue_batches", force: :cascade do |t|
    t.string "active_job_batch_id"
    t.integer "completed_jobs", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "enqueued_at"
    t.datetime "failed_at"
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "finished_at"
    t.text "metadata"
    t.text "on_failure"
    t.text "on_finish"
    t.text "on_success"
    t.integer "total_jobs", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_batch_id"], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
    t.index ["finished_at"], name: "index_solid_queue_batches_on_finished_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.bigint "batch_id"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["batch_id"], name: "index_solid_queue_jobs_on_batch_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "tours", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "cancellation_policy"
    t.datetime "created_at", null: false
    t.string "currency"
    t.text "description", null: false
    t.bigint "destination_id"
    t.string "duration"
    t.string "excluded", default: [], array: true
    t.boolean "featured", default: false, null: false
    t.string "group_size"
    t.string "highlights", default: [], array: true
    t.string "included", default: [], array: true
    t.jsonb "itinerary", default: []
    t.string "languages", default: [], array: true
    t.text "meeting_point"
    t.decimal "price_from", precision: 10, scale: 2
    t.string "slug", null: false
    t.string "title", null: false
    t.string "tour_type"
    t.jsonb "translations", default: {}
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tours_on_active"
    t.index ["destination_id"], name: "index_tours_on_destination_id"
    t.index ["featured"], name: "index_tours_on_featured"
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
    t.jsonb "translations", default: {}
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

  create_table "trip_services", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.bigint "driver_id"
    t.string "dropoff_location"
    t.time "end_time"
    t.text "notes"
    t.string "pickup_location"
    t.string "service_type", null: false
    t.time "start_time"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id"
    t.index ["booking_id"], name: "index_trip_services_on_booking_id"
    t.index ["date"], name: "index_trip_services_on_date"
    t.index ["driver_id"], name: "index_trip_services_on_driver_id"
    t.index ["service_type"], name: "index_trip_services_on_service_type"
    t.index ["status"], name: "index_trip_services_on_status"
    t.index ["vehicle_id"], name: "index_trip_services_on_vehicle_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.string "ownership_type"
    t.string "plate_number", null: false
    t.datetime "updated_at", null: false
    t.string "vehicle_type"
    t.index ["active"], name: "index_vehicles_on_active"
    t.index ["plate_number"], name: "index_vehicles_on_plate_number", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_requests", "tours"
  add_foreign_key "bookings", "booking_requests"
  add_foreign_key "bookings", "customers"
  add_foreign_key "bookings", "trip_inquiries"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_batch_executions", "solid_queue_batches", column: "batch_id", on_delete: :cascade
  add_foreign_key "solid_queue_batch_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "tours", "destinations"
  add_foreign_key "trip_inquiries", "accommodations"
  add_foreign_key "trip_inquiries", "packages"
  add_foreign_key "trip_services", "bookings"
  add_foreign_key "trip_services", "drivers"
  add_foreign_key "trip_services", "vehicles"
end
