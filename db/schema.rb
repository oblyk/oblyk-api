# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_30_180010) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "alerts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.string "alert_type"
    t.bigint "user_id"
    t.string "alertable_type"
    t.bigint "alertable_id"
    t.datetime "alerted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["alertable_type", "alertable_id"], name: "index_alerts_on_alertable_type_and_alertable_id"
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "approaches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "polyline"
    t.text "description"
    t.integer "length"
    t.string "approach_type"
    t.bigint "crag_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crag_id"], name: "index_approaches_on_crag_id"
    t.index ["user_id"], name: "index_approaches_on_user_id"
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "conversation_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.bigint "conversation_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "posted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conversation_id"], name: "index_conversation_messages_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_messages_on_user_id"
  end

  create_table "conversation_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conversation_id"
    t.bigint "user_id"
    t.datetime "last_read_at"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conversation_id"], name: "index_conversation_users_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_users_on_user_id"
  end

  create_table "conversations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "crag_routes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "height"
    t.integer "open_year"
    t.string "opener"
    t.json "sections"
    t.string "climbing_type"
    t.string "incline_type"
    t.string "reception_type"
    t.string "start_type"
    t.integer "difficulty_appreciation"
    t.integer "note"
    t.integer "note_count"
    t.integer "ascents_count"
    t.integer "sections_count"
    t.integer "max_grade_value"
    t.integer "min_grade_value"
    t.text "max_grade_text"
    t.text "min_grade_text"
    t.integer "max_bolt"
    t.bigint "crag_id"
    t.bigint "crag_sector_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["crag_id"], name: "index_crag_routes_on_crag_id"
    t.index ["crag_sector_id"], name: "index_crag_routes_on_crag_sector_id"
    t.index ["name"], name: "index_crag_routes_on_name"
    t.index ["user_id"], name: "index_crag_routes_on_user_id"
  end

  create_table "crag_sectors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "rain"
    t.string "sun"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.boolean "north"
    t.boolean "north_east"
    t.boolean "east"
    t.boolean "south_east"
    t.boolean "south"
    t.boolean "south_west"
    t.boolean "west"
    t.boolean "north_west"
    t.bigint "user_id"
    t.bigint "crag_id"
    t.integer "crag_routes_count"
    t.integer "min_grade_value"
    t.integer "max_grade_value"
    t.string "max_grade_text"
    t.string "min_grade_text"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["crag_id"], name: "index_crag_sectors_on_crag_id"
    t.index ["name"], name: "index_crag_sectors_on_name"
    t.index ["user_id"], name: "index_crag_sectors_on_user_id"
  end

  create_table "crags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.json "rocks"
    t.string "rain"
    t.string "sun"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "code_country"
    t.string "country"
    t.string "city"
    t.string "region"
    t.boolean "sport_climbing", default: false
    t.boolean "bouldering", default: false
    t.boolean "multi_pitch", default: false
    t.boolean "trad_climbing", default: false
    t.boolean "aid_climbing", default: false
    t.boolean "deep_water", default: false
    t.boolean "via_ferrata", default: false
    t.boolean "summer"
    t.boolean "autumn"
    t.boolean "winter"
    t.boolean "spring"
    t.boolean "north"
    t.boolean "north_east"
    t.boolean "east"
    t.boolean "south_east"
    t.boolean "south"
    t.boolean "south_west"
    t.boolean "west"
    t.boolean "north_west"
    t.bigint "user_id"
    t.integer "crag_routes_count"
    t.integer "min_grade_value"
    t.integer "max_grade_value"
    t.string "max_grade_text"
    t.string "min_grade_text"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["name"], name: "index_crags_on_name"
    t.index ["user_id"], name: "index_crags_on_user_id"
  end

  create_table "follows", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "followable_type"
    t.bigint "followable_id"
    t.bigint "user_id"
    t.datetime "accepted_at"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.text "description"
    t.string "linkable_type"
    t.bigint "linkable_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id"
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "parks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.bigint "crag_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crag_id"], name: "index_parks_on_crag_id"
    t.index ["user_id"], name: "index_parks_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.date "date_of_birth"
    t.string "genre"
    t.text "description"
    t.boolean "public", default: false
    t.boolean "partner_search", default: false
    t.datetime "newsletter_accepted_at"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.boolean "bouldering", default: false
    t.boolean "sport_climbing", default: false
    t.boolean "multi_pitch", default: false
    t.boolean "trad_climbing", default: false
    t.boolean "aid_climbing", default: false
    t.boolean "deep_water", default: false
    t.boolean "via_ferrata", default: false
    t.boolean "pan", default: false
    t.string "grade_max"
    t.string "grade_min"
    t.boolean "super_admin", default: false
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "words", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "definition"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_words_on_name", unique: true
    t.index ["user_id"], name: "index_words_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
