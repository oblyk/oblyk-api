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

ActiveRecord::Schema.define(version: 2021_01_15_151900) do

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

  create_table "area_crags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "crag_id"
    t.bigint "area_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area_id"], name: "index_area_crags_on_area_id"
    t.index ["crag_id"], name: "index_area_crags_on_crag_id"
    t.index ["user_id"], name: "index_area_crags_on_user_id"
  end

  create_table "areas", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug_name"
    t.index ["user_id"], name: "index_areas_on_user_id"
  end

  create_table "ascents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.string "ascent_status"
    t.string "roping_status"
    t.integer "attempt"
    t.bigint "user_id"
    t.bigint "crag_route_id"
    t.bigint "gym_route_id"
    t.json "sections"
    t.integer "height"
    t.json "hold_colors"
    t.json "tag_colors"
    t.string "climbing_type"
    t.string "grade_appreciation_text"
    t.integer "grade_appreciation_value"
    t.integer "note"
    t.text "comment"
    t.integer "sections_count"
    t.integer "max_grade_value"
    t.integer "min_grade_value"
    t.text "max_grade_text"
    t.text "min_grade_text"
    t.string "legacy_hardness_id"
    t.bigint "legacy_id"
    t.date "released_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "points"
    t.index ["crag_route_id"], name: "index_ascents_on_crag_route_id"
    t.index ["gym_route_id"], name: "index_ascents_on_gym_route_id"
    t.index ["user_id"], name: "index_ascents_on_user_id"
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
    t.bigint "photo_id"
    t.string "slug_name"
    t.index ["crag_id"], name: "index_crag_routes_on_crag_id"
    t.index ["crag_sector_id"], name: "index_crag_routes_on_crag_sector_id"
    t.index ["name"], name: "index_crag_routes_on_name"
    t.index ["photo_id"], name: "index_crag_routes_on_photo_id"
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
    t.bigint "photo_id"
    t.string "slug_name"
    t.index ["crag_id"], name: "index_crag_sectors_on_crag_id"
    t.index ["name"], name: "index_crag_sectors_on_name"
    t.index ["photo_id"], name: "index_crag_sectors_on_photo_id"
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
    t.bigint "photo_id"
    t.string "slug_name"
    t.index ["name"], name: "index_crags_on_name"
    t.index ["photo_id"], name: "index_crags_on_photo_id"
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
    t.integer "views", default: 0
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "guide_book_paper_crags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "crag_id"
    t.bigint "guide_book_paper_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crag_id", "guide_book_paper_id"], name: "index_guide_book_paper_crags_on_crag_id_and_guide_book_paper_id", unique: true
    t.index ["crag_id"], name: "index_guide_book_paper_crags_on_crag_id"
    t.index ["guide_book_paper_id"], name: "index_guide_book_paper_crags_on_guide_book_paper_id"
    t.index ["user_id"], name: "index_guide_book_paper_crags_on_user_id"
  end

  create_table "guide_book_papers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "author"
    t.string "editor"
    t.integer "publication_year"
    t.integer "price_cents"
    t.string "ean"
    t.string "vc_reference"
    t.integer "number_of_page"
    t.integer "weight"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug_name"
    t.index ["user_id"], name: "index_guide_book_papers_on_user_id"
  end

  create_table "guide_book_pdfs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "author"
    t.integer "publication_year"
    t.bigint "crag_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crag_id"], name: "index_guide_book_pdfs_on_crag_id"
    t.index ["user_id"], name: "index_guide_book_pdfs_on_user_id"
  end

  create_table "guide_book_webs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.integer "publication_year"
    t.bigint "user_id"
    t.bigint "crag_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crag_id"], name: "index_guide_book_webs_on_crag_id"
    t.index ["user_id"], name: "index_guide_book_webs_on_user_id"
  end

  create_table "gym_administration_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "gym_id"
    t.bigint "user_id"
    t.text "justification"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_administration_requests_on_gym_id"
    t.index ["user_id"], name: "index_gym_administration_requests_on_user_id"
  end

  create_table "gym_administrators", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "gym_id"
    t.string "level"
    t.index ["gym_id"], name: "index_gym_administrators_on_gym_id"
    t.index ["user_id"], name: "index_gym_administrators_on_user_id"
  end

  create_table "gym_grade_lines", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.json "colors"
    t.integer "order"
    t.string "grade_text"
    t.integer "grade_value"
    t.bigint "gym_grade_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "points"
    t.index ["gym_grade_id"], name: "index_gym_grade_lines_on_gym_grade_id"
  end

  create_table "gym_grades", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "difficulty_system"
    t.boolean "has_hold_color"
    t.bigint "gym_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "use_grade_system", default: false
    t.boolean "use_point_system", default: false
    t.boolean "use_point_division_system", default: false
    t.index ["gym_id"], name: "index_gym_grades_on_gym_id"
  end

  create_table "gym_routes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "height"
    t.string "climbing_type"
    t.string "openers"
    t.text "polyline"
    t.json "hold_colors"
    t.json "tag_colors"
    t.json "sections"
    t.bigint "gym_sector_id"
    t.bigint "gym_grade_line_id"
    t.integer "grade_value_appreciation"
    t.integer "note"
    t.integer "note_count"
    t.integer "ascents_count"
    t.integer "sections_count"
    t.integer "max_grade_value"
    t.integer "min_grade_value"
    t.text "max_grade_text"
    t.text "min_grade_text"
    t.bigint "legacy_id"
    t.datetime "archived_at"
    t.date "opened_at"
    t.datetime "dismounted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "points"
    t.index ["gym_grade_line_id"], name: "index_gym_routes_on_gym_grade_line_id"
    t.index ["gym_sector_id"], name: "index_gym_routes_on_gym_sector_id"
  end

  create_table "gym_sectors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "group_sector_name"
    t.string "climbing_type"
    t.integer "height"
    t.text "polygon"
    t.bigint "gym_space_id"
    t.bigint "gym_grade_id"
    t.bigint "legacy_id"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "can_be_more_than_one_pitch", default: false
    t.index ["gym_grade_id"], name: "index_gym_sectors_on_gym_grade_id"
    t.index ["gym_space_id"], name: "index_gym_sectors_on_gym_space_id"
  end

  create_table "gym_spaces", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "order"
    t.string "climbing_type"
    t.string "banner_color"
    t.string "banner_bg_color"
    t.integer "banner_opacity"
    t.string "scheme_bg_color"
    t.integer "scheme_height"
    t.integer "scheme_width"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.bigint "gym_id"
    t.bigint "gym_grade_id"
    t.bigint "legacy_id"
    t.datetime "deleted_at"
    t.datetime "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug_name"
    t.index ["gym_grade_id"], name: "index_gym_spaces_on_gym_grade_id"
    t.index ["gym_id"], name: "index_gym_spaces_on_gym_id"
  end

  create_table "gyms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "address"
    t.string "postal_code"
    t.string "code_country"
    t.string "country"
    t.string "city"
    t.string "big_city"
    t.string "region"
    t.string "email"
    t.string "phone_number"
    t.string "web_site"
    t.boolean "bouldering"
    t.boolean "sport_climbing"
    t.boolean "pan"
    t.boolean "fun_climbing"
    t.boolean "training_space"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.bigint "user_id"
    t.string "plan"
    t.datetime "plan_start_at"
    t.datetime "plan_en_at"
    t.datetime "assigned_at"
    t.bigint "legacy_id"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug_name"
    t.index ["name"], name: "index_gyms_on_name"
    t.index ["user_id"], name: "index_gyms_on_user_id"
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

  create_table "photos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.string "exif_model"
    t.string "exif_make"
    t.string "source"
    t.string "alt"
    t.boolean "copyright_by"
    t.boolean "copyright_nc"
    t.boolean "copyright_nd"
    t.bigint "user_id"
    t.string "illustrable_type"
    t.bigint "illustrable_id"
    t.bigint "legacy_id"
    t.datetime "posted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["illustrable_type", "illustrable_id"], name: "index_photos_on_illustrable_type_and_illustrable_id"
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "place_of_sales", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.text "description"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "code_country"
    t.string "country"
    t.string "postal_code"
    t.string "city"
    t.string "region"
    t.string "address"
    t.bigint "guide_book_paper_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["guide_book_paper_id"], name: "index_place_of_sales_on_guide_book_paper_id"
    t.index ["user_id"], name: "index_place_of_sales_on_user_id"
  end

  create_table "refresh_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token"
    t.string "user_agent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["token"], name: "index_refresh_tokens_on_token"
    t.index ["user_agent"], name: "index_refresh_tokens_on_user_agent"
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "report_from_url"
    t.string "reportable_type"
    t.bigint "reportable_id"
    t.text "body"
    t.bigint "user_id"
    t.datetime "processed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "subscribes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email"
    t.datetime "subscribed_at"
    t.integer "error"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_subscribes_on_email", unique: true
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["taggable_type", "taggable_id"], name: "index_tags_on_taggable_type_and_taggable_id"
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "tick_lists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "crag_route_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crag_route_id"], name: "index_tick_lists_on_crag_route_id"
    t.index ["user_id"], name: "index_tick_lists_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.date "date_of_birth"
    t.string "genre"
    t.text "description"
    t.boolean "public"
    t.boolean "partner_search"
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
    t.string "slug_name"
    t.string "localization"
    t.string "language", default: "fr"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expired_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "videos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.string "url"
    t.bigint "user_id"
    t.string "viewable_type"
    t.bigint "viewable_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_videos_on_user_id"
    t.index ["viewable_type", "viewable_id"], name: "index_videos_on_viewable_type_and_viewable_id"
  end

  create_table "words", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "definition"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug_name"
    t.index ["name"], name: "index_words_on_name", unique: true
    t.index ["user_id"], name: "index_words_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
