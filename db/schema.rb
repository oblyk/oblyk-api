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

ActiveRecord::Schema.define(version: 2025_06_21_135339) do

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
    t.json "polyline"
    t.text "description"
    t.integer "length"
    t.string "approach_type"
    t.bigint "crag_id"
    t.bigint "user_id"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "path_metadata"
    t.boolean "from_park", default: true
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
    t.integer "comments_count"
    t.bigint "photo_id"
    t.index ["photo_id"], name: "index_areas_on_photo_id"
    t.index ["user_id"], name: "index_areas_on_user_id"
  end

  create_table "article_crags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "crag_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["article_id"], name: "index_article_crags_on_article_id"
    t.index ["crag_id", "article_id"], name: "unique_crag_and_article_index", unique: true
    t.index ["crag_id"], name: "index_article_crags_on_crag_id"
  end

  create_table "article_guide_book_papers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "guide_book_paper_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["article_id"], name: "index_article_guide_book_papers_on_article_id"
    t.index ["guide_book_paper_id", "article_id"], name: "unique_guide_book_and_article_index", unique: true
    t.index ["guide_book_paper_id"], name: "index_article_guide_book_papers_on_guide_book_paper_id"
  end

  create_table "articles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.text "description"
    t.text "body"
    t.integer "views"
    t.integer "comments_count"
    t.bigint "author_id"
    t.datetime "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "photos_count"
    t.integer "likes_count"
    t.index ["author_id"], name: "index_articles_on_author_id"
  end

  create_table "ascent_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "ascent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ascent_id"], name: "index_ascent_users_on_ascent_id"
    t.index ["user_id", "ascent_id"], name: "index_ascent_users_on_user_id_and_ascent_id", unique: true
    t.index ["user_id"], name: "index_ascent_users_on_user_id"
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
    t.string "climbing_type"
    t.integer "note"
    t.text "comment"
    t.integer "comments_count"
    t.integer "sections_count"
    t.integer "max_grade_value"
    t.integer "min_grade_value"
    t.text "max_grade_text"
    t.text "min_grade_text"
    t.bigint "legacy_id"
    t.date "released_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "points"
    t.boolean "private_comment"
    t.string "hardness_status"
    t.integer "gym_grade_level"
    t.bigint "gym_id"
    t.bigint "gym_grade_id"
    t.integer "quantity", default: 1
    t.bigint "climbing_session_id"
    t.bigint "color_system_line_id"
    t.index ["climbing_session_id"], name: "index_ascents_on_climbing_session_id"
    t.index ["color_system_line_id"], name: "index_ascents_on_color_system_line_id"
    t.index ["crag_route_id"], name: "index_ascents_on_crag_route_id"
    t.index ["gym_grade_id"], name: "index_ascents_on_gym_grade_id"
    t.index ["gym_id"], name: "index_ascents_on_gym_id"
    t.index ["gym_route_id"], name: "index_ascents_on_gym_route_id"
    t.index ["user_id"], name: "index_ascents_on_user_id"
  end

  create_table "authors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "championship_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.bigint "championship_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["championship_id"], name: "index_championship_categories_on_championship_id"
  end

  create_table "championship_category_matches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "championship_category_id"
    t.bigint "contest_category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["championship_category_id"], name: "index_championship_category_matches_on_championship_category_id"
    t.index ["contest_category_id"], name: "index_championship_category_matches_on_contest_category_id"
  end

  create_table "championship_contests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.bigint "championship_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["championship_id"], name: "index_championship_contests_on_championship_id"
    t.index ["contest_id"], name: "index_championship_contests_on_contest_id"
  end

  create_table "championships", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.text "description"
    t.string "combined_ranking_type"
    t.bigint "gym_id"
    t.datetime "archived_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_championships_on_gym_id"
  end

  create_table "climbing_sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.date "session_date"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_date"], name: "index_climbing_sessions_on_session_date"
    t.index ["user_id"], name: "index_climbing_sessions_on_user_id"
  end

  create_table "color_system_lines", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "color_system_id"
    t.string "hex_color"
    t.integer "order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["color_system_id"], name: "index_color_system_lines_on_color_system_id"
  end

  create_table "color_systems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "colors_mark"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["colors_mark"], name: "index_color_systems_on_colors_mark", unique: true
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "user_id"
    t.bigint "reply_to_comment_id"
    t.integer "likes_count"
    t.integer "comments_count"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "moderated_at"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["reply_to_comment_id"], name: "index_comments_on_reply_to_comment_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contest_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.text "description"
    t.integer "order"
    t.integer "capacity"
    t.boolean "unisex"
    t.string "registration_obligation"
    t.integer "min_age"
    t.integer "max_age"
    t.boolean "auto_distribute"
    t.boolean "waveable"
    t.integer "contest_participants_count"
    t.bigint "contest_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "parity", default: false
    t.index ["contest_id"], name: "index_contest_categories_on_contest_id"
  end

  create_table "contest_participant_ascents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_participant_id"
    t.bigint "contest_route_id"
    t.datetime "registered_at"
    t.boolean "realised"
    t.integer "zone_1_attempt"
    t.integer "zone_2_attempt"
    t.integer "top_attempt"
    t.integer "hold_number"
    t.boolean "hold_number_plus"
    t.time "ascent_time", precision: 3
    t.index ["contest_participant_id"], name: "index_contest_participant_ascents_on_contest_participant_id"
    t.index ["contest_route_id"], name: "index_contest_participant_ascents_on_contest_route_id"
  end

  create_table "contest_participant_steps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ranking"
    t.bigint "contest_participant_id"
    t.bigint "contest_stage_step_id"
    t.index ["contest_participant_id"], name: "index_contest_participant_steps_on_contest_participant_id"
    t.index ["contest_stage_step_id"], name: "index_contest_participant_steps_on_contest_stage_step_id"
  end

  create_table "contest_participants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "genre"
    t.string "email"
    t.string "affiliation"
    t.string "token"
    t.bigint "contest_category_id"
    t.bigint "user_id"
    t.bigint "contest_wave_id"
    t.boolean "tombola_winner", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "contest_team_id"
    t.index ["contest_category_id"], name: "index_contest_participants_on_contest_category_id"
    t.index ["contest_team_id"], name: "index_contest_participants_on_contest_team_id"
    t.index ["contest_wave_id"], name: "index_contest_participants_on_contest_wave_id"
    t.index ["token"], name: "index_contest_participants_on_token"
    t.index ["user_id"], name: "index_contest_participants_on_user_id"
  end

  create_table "contest_route_group_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_route_group_id"
    t.bigint "contest_category_id"
    t.index ["contest_category_id"], name: "index_contest_route_group_categories_on_contest_category_id"
    t.index ["contest_route_group_id"], name: "index_contest_route_group_categories_on_contest_route_group_id"
  end

  create_table "contest_route_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "waveable"
    t.date "route_group_date"
    t.time "start_time"
    t.time "end_time"
    t.date "start_date"
    t.date "end_date"
    t.integer "additional_time", default: 20
    t.string "genre_type"
    t.integer "number_participants_for_next_step"
    t.bigint "contest_stage_step_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contest_stage_step_id"], name: "index_contest_route_groups_on_contest_stage_step_id"
  end

  create_table "contest_routes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.integer "number_of_holds"
    t.integer "fixed_points"
    t.boolean "additional_zone"
    t.datetime "disabled_at"
    t.bigint "contest_route_group_id"
    t.bigint "gym_route_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contest_route_group_id"], name: "index_contest_routes_on_contest_route_group_id"
    t.index ["gym_route_id"], name: "index_contest_routes_on_gym_route_id"
  end

  create_table "contest_stage_steps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.integer "step_order"
    t.string "ranking_type"
    t.integer "ascents_limit"
    t.boolean "self_reporting"
    t.integer "default_participants_for_next_step"
    t.bigint "contest_stage_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contest_stage_id"], name: "index_contest_stage_steps_on_contest_stage_id"
  end

  create_table "contest_stages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "climbing_type"
    t.string "name"
    t.text "description"
    t.integer "stage_order"
    t.string "default_ranking_type"
    t.date "stage_date"
    t.bigint "contest_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contest_id"], name: "index_contest_stages_on_contest_id"
  end

  create_table "contest_teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "contest_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contest_id"], name: "index_contest_teams_on_contest_id"
    t.index ["name", "contest_id"], name: "index_contest_teams_on_name_and_contest_id", unique: true
  end

  create_table "contest_time_blocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.time "start_time"
    t.time "end_time"
    t.date "start_date"
    t.date "end_date"
    t.integer "additional_time", default: 20
    t.bigint "contest_wave_id"
    t.bigint "contest_route_group_id"
    t.index ["contest_route_group_id"], name: "index_contest_time_blocks_on_contest_route_group_id"
    t.index ["contest_wave_id"], name: "index_contest_time_blocks_on_contest_wave_id"
  end

  create_table "contest_waves", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "contest_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "capacity"
    t.index ["contest_id"], name: "index_contest_waves_on_contest_id"
  end

  create_table "contests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "gym_id"
    t.string "name"
    t.string "slug_name"
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.date "subscription_start_date"
    t.date "subscription_end_date"
    t.datetime "subscription_closed_at"
    t.integer "total_capacity"
    t.string "categorization_type"
    t.integer "contest_participants_count"
    t.datetime "archived_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.boolean "draft"
    t.boolean "authorise_public_subscription", default: true
    t.boolean "private", default: false
    t.boolean "hide_results", default: false
    t.string "combined_ranking_type"
    t.boolean "team_contest", default: false
    t.integer "participant_per_team", default: 0
    t.index ["gym_id"], name: "index_contests_on_gym_id"
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
    t.datetime "last_message_at"
  end

  create_table "countries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.string "code_country", limit: 5
    t.json "geo_polygon"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_countries_on_name"
    t.index ["slug_name"], name: "index_countries_on_slug_name", unique: true
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
    t.float "difficulty_appreciation"
    t.float "note"
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
    t.integer "comments_count"
    t.integer "videos_count"
    t.integer "photos_count"
    t.json "location"
    t.json "votes"
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
    t.integer "comments_count"
    t.integer "photos_count"
    t.json "location"
    t.decimal "elevation", precision: 10, scale: 6
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
    t.integer "comments_count"
    t.integer "videos_count"
    t.integer "photos_count"
    t.integer "follows_count"
    t.integer "articles_count"
    t.decimal "elevation", precision: 10, scale: 6
    t.bigint "department_id"
    t.integer "min_approach_time"
    t.integer "max_approach_time"
    t.index ["department_id"], name: "index_crags_on_department_id"
    t.index ["name"], name: "index_crags_on_name"
    t.index ["photo_id"], name: "index_crags_on_photo_id"
    t.index ["user_id"], name: "index_crags_on_user_id"
  end

  create_table "departments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.string "department_number", limit: 5
    t.string "name_prefix_type"
    t.string "in_sentence_prefix_type"
    t.json "geo_polygon"
    t.bigint "country_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_departments_on_country_id"
    t.index ["department_number"], name: "index_departments_on_department_number"
    t.index ["name"], name: "index_departments_on_name"
    t.index ["slug_name"], name: "index_departments_on_slug_name", unique: true
  end

  create_table "feeds", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "feedable_type"
    t.bigint "feedable_id"
    t.json "feed_object"
    t.string "parent_type"
    t.bigint "parent_id"
    t.json "parent_object"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "posted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feedable_type", "feedable_id"], name: "index_feeds_on_feedable_type_and_feedable_id"
    t.index ["latitude"], name: "index_feeds_on_latitude"
    t.index ["longitude"], name: "index_feeds_on_longitude"
    t.index ["parent_id"], name: "index_feeds_on_parent_id"
    t.index ["parent_type"], name: "index_feeds_on_parent_type"
    t.index ["posted_at"], name: "index_feeds_on_posted_at"
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
    t.integer "follows_count"
    t.integer "articles_count"
    t.integer "comments_count"
    t.string "funding_status"
    t.bigint "next_guide_book_paper_id"
    t.index ["next_guide_book_paper_id"], name: "index_guide_book_papers_on_next_guide_book_paper_id"
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
    t.json "roles"
    t.string "requested_email"
    t.boolean "subscribe_to_comment_feed"
    t.boolean "subscribe_to_video_feed"
    t.boolean "subscribe_to_follower_feed"
    t.datetime "last_comment_feed_read_at"
    t.datetime "last_video_feed_read_at"
    t.datetime "last_follower_feed_read_at"
    t.boolean "email_report", default: true
    t.index ["gym_id"], name: "index_gym_administrators_on_gym_id"
    t.index ["user_id"], name: "index_gym_administrators_on_user_id"
  end

  create_table "gym_billing_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "uuid"
    t.string "customer_stripe_id"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uuid"], name: "index_gym_billing_accounts_on_uuid"
  end

  create_table "gym_chain_administrators", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "gym_chain_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_chain_id"], name: "index_gym_chain_administrators_on_gym_chain_id"
    t.index ["user_id"], name: "index_gym_chain_administrators_on_user_id"
  end

  create_table "gym_chain_gyms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "gym_chain_id"
    t.bigint "gym_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_chain_id"], name: "index_gym_chain_gyms_on_gym_chain_id"
    t.index ["gym_id"], name: "index_gym_chain_gyms_on_gym_id"
  end

  create_table "gym_chains", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.text "description"
    t.boolean "public_chain"
    t.string "api_access_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["api_access_token"], name: "index_gym_chains_on_api_access_token", unique: true
    t.index ["slug_name"], name: "index_gym_chains_on_slug_name", unique: true
  end

  create_table "gym_climbing_styles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "style"
    t.string "climbing_type"
    t.string "color"
    t.bigint "gym_id"
    t.datetime "deactivated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_climbing_styles_on_gym_id"
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
    t.datetime "deleted_at"
    t.integer "points"
    t.index ["gym_grade_id"], name: "index_gym_grade_lines_on_gym_grade_id"
  end

  create_table "gym_grades", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "gym_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.boolean "difficulty_by_grade", default: false
    t.boolean "difficulty_by_level"
    t.boolean "tag_color"
    t.boolean "hold_color"
    t.string "point_system_type", default: "none"
    t.index ["gym_id"], name: "index_gym_grades_on_gym_id"
  end

  create_table "gym_label_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "label_direction"
    t.json "layout_options"
    t.json "label_options"
    t.json "header_options"
    t.json "footer_options"
    t.json "border_style"
    t.string "font_family"
    t.string "qr_code_position"
    t.string "label_arrangement"
    t.string "grade_style"
    t.boolean "display_points"
    t.boolean "display_openers"
    t.boolean "display_opened_at"
    t.boolean "display_name"
    t.boolean "display_description"
    t.boolean "display_anchor"
    t.boolean "display_climbing_style"
    t.boolean "display_grade"
    t.boolean "display_tag_and_hold"
    t.string "page_format"
    t.string "page_direction"
    t.bigint "gym_id"
    t.datetime "archived_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_label_templates_on_gym_id"
  end

  create_table "gym_levels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "gym_id"
    t.string "climbing_type"
    t.boolean "enabled", default: true
    t.string "grade_system"
    t.string "level_representation"
    t.json "levels"
    t.index ["gym_id", "climbing_type"], name: "index_gym_levels_on_gym_id_and_climbing_type", unique: true
    t.index ["gym_id"], name: "index_gym_levels_on_gym_id"
  end

  create_table "gym_openers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "first_name"
    t.string "last_name"
    t.string "slug_name"
    t.string "email"
    t.bigint "user_id"
    t.bigint "gym_id"
    t.datetime "deactivated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_openers_on_gym_id"
    t.index ["user_id"], name: "index_gym_openers_on_user_id"
  end

  create_table "gym_opening_sheets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.json "row_json"
    t.integer "number_of_columns"
    t.datetime "archived_at"
    t.bigint "gym_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_opening_sheets_on_gym_id"
  end

  create_table "gym_options", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "gym_id"
    t.string "option_type"
    t.date "start_date"
    t.date "end_date"
    t.boolean "unlimited_unit"
    t.integer "remaining_unit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_options_on_gym_id"
  end

  create_table "gym_route_covers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "gym_route_openers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "gym_opener_id"
    t.bigint "gym_route_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_opener_id"], name: "index_gym_route_openers_on_gym_opener_id"
    t.index ["gym_route_id"], name: "index_gym_route_openers_on_gym_route_id"
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
    t.bigint "gym_route_cover_id"
    t.bigint "gym_grade_line_id"
    t.integer "note"
    t.integer "note_count"
    t.integer "ascents_count"
    t.integer "sections_count"
    t.integer "max_grade_value"
    t.integer "min_grade_value"
    t.text "max_grade_text"
    t.text "min_grade_text"
    t.integer "level_index"
    t.integer "level_length"
    t.string "level_color"
    t.bigint "legacy_id"
    t.datetime "archived_at"
    t.date "opened_at"
    t.datetime "dismounted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "points"
    t.integer "comments_count"
    t.integer "all_comments_count", default: 0
    t.integer "likes_count"
    t.integer "videos_count"
    t.text "description"
    t.json "thumbnail_position"
    t.float "difficulty_appreciation"
    t.json "votes"
    t.integer "anchor_number"
    t.index ["gym_grade_line_id"], name: "index_gym_routes_on_gym_grade_line_id"
    t.index ["gym_route_cover_id"], name: "index_gym_routes_on_gym_route_cover_id"
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
    t.integer "order", default: 0
    t.integer "min_anchor_number"
    t.integer "max_anchor_number"
    t.json "three_d_path"
    t.decimal "three_d_height", precision: 10, scale: 6
    t.decimal "three_d_elevated", precision: 10, scale: 6, default: "0.0"
    t.json "three_d_label_options"
    t.float "linear_metre"
    t.float "developed_metre"
    t.string "category_name"
    t.integer "average_opening_time"
    t.index ["gym_grade_id"], name: "index_gym_sectors_on_gym_grade_id"
    t.index ["gym_space_id"], name: "index_gym_sectors_on_gym_space_id"
  end

  create_table "gym_space_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "gym_id"
    t.string "name"
    t.integer "order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_space_groups_on_gym_id"
  end

  create_table "gym_spaces", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "order"
    t.string "climbing_type"
    t.integer "scheme_height"
    t.integer "scheme_width"
    t.string "sectors_color"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.bigint "gym_id"
    t.bigint "gym_grade_id"
    t.bigint "legacy_id"
    t.datetime "deleted_at"
    t.datetime "archived_at"
    t.boolean "draft", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug_name"
    t.bigint "gym_space_group_id"
    t.boolean "anchor"
    t.json "three_d_parameters"
    t.json "three_d_position"
    t.decimal "three_d_scale", precision: 10, scale: 6, default: "1.0"
    t.json "three_d_rotation"
    t.json "three_d_camera_position"
    t.json "three_d_label_options"
    t.string "representation_type", default: "2d_picture"
    t.index ["gym_grade_id"], name: "index_gym_spaces_on_gym_grade_id"
    t.index ["gym_id"], name: "index_gym_spaces_on_gym_id"
    t.index ["gym_space_group_id"], name: "index_gym_spaces_on_gym_space_group_id"
  end

  create_table "gym_three_d_assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.text "description"
    t.json "three_d_parameters"
    t.bigint "gym_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_three_d_assets_on_gym_id"
  end

  create_table "gym_three_d_elements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.json "three_d_position"
    t.json "three_d_rotation"
    t.text "message"
    t.string "url"
    t.decimal "three_d_scale", precision: 10, scale: 6, default: "1.0"
    t.bigint "gym_three_d_asset_id"
    t.bigint "gym_id"
    t.bigint "gym_space_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gym_id"], name: "index_gym_three_d_elements_on_gym_id"
    t.index ["gym_space_id"], name: "index_gym_three_d_elements_on_gym_space_id"
    t.index ["gym_three_d_asset_id"], name: "index_gym_three_d_elements_on_gym_three_d_asset_id"
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
    t.string "sport_climbing_ranking"
    t.string "pan_ranking"
    t.string "boulder_ranking"
    t.json "ascents_multiplier"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.bigint "user_id"
    t.string "plan"
    t.datetime "plan_start_at"
    t.datetime "plan_end_at"
    t.datetime "assigned_at"
    t.bigint "legacy_id"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug_name"
    t.integer "follows_count"
    t.integer "comments_count"
    t.integer "videos_count"
    t.bigint "department_id"
    t.string "representation_type", default: "2d_picture"
    t.json "three_d_camera_position"
    t.string "gym_type"
    t.bigint "gym_billing_account_id"
    t.index ["department_id"], name: "index_gyms_on_department_id"
    t.index ["gym_billing_account_id"], name: "index_gyms_on_gym_billing_account_id"
    t.index ["name"], name: "index_gyms_on_name"
    t.index ["user_id"], name: "index_gyms_on_user_id"
  end

  create_table "indoor_subscription_gyms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "indoor_subscription_id"
    t.bigint "gym_id"
    t.index ["gym_id"], name: "index_indoor_subscription_gyms_on_gym_id"
    t.index ["indoor_subscription_id"], name: "index_indoor_subscription_gyms_on_indoor_subscription_id"
  end

  create_table "indoor_subscription_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "reference"
    t.integer "order"
    t.boolean "recommended"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "USD", null: false
    t.string "for_gym_type"
    t.integer "month_by_occurrence"
    t.string "product_stripe_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "indoor_subscriptions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "for_gym_type"
    t.integer "month_by_occurrence"
    t.date "start_date"
    t.date "trial_end_date"
    t.date "end_date"
    t.datetime "cancelled_at"
    t.string "payment_link"
    t.string "payment_status"
    t.string "subscription_stripe_id"
    t.string "payment_link_stipe_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ip_black_lists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "ip"
    t.text "params_sent"
    t.integer "block_count"
    t.datetime "blocked_at"
    t.datetime "block_expired_at"
    t.index ["block_expired_at"], name: "index_ip_black_lists_on_block_expired_at"
    t.index ["ip"], name: "index_ip_black_lists_on_ip"
  end

  create_table "likes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "likeable_type"
    t.bigint "likeable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
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

  create_table "localities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "code_country"
    t.string "region"
    t.integer "partner_search_users_count"
    t.integer "local_sharing_users_count"
    t.integer "distinct_users_count"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["latitude"], name: "index_localities_on_latitude"
    t.index ["longitude"], name: "index_localities_on_longitude"
  end

  create_table "locality_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "locality_id"
    t.boolean "partner_search"
    t.boolean "local_sharing"
    t.text "description"
    t.integer "radius"
    t.datetime "deactivated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["locality_id"], name: "index_locality_users_on_locality_id"
    t.index ["user_id"], name: "index_locality_users_on_user_id"
  end

  create_table "newsletters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.text "body"
    t.integer "photos_count"
    t.datetime "sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "notification_type"
    t.bigint "user_id"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.datetime "posted_at"
    t.datetime "read_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["posted_at"], name: "index_notifications_on_posted_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organization_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_organization_users_on_organization_id"
    t.index ["user_id"], name: "index_organization_users_on_user_id"
  end

  create_table "organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "api_access_token"
    t.string "api_usage_type"
    t.string "phone"
    t.string "email"
    t.string "address"
    t.string "city"
    t.string "zipcode"
    t.string "website"
    t.string "company_registration_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.string "slug_name"
    t.index ["api_access_token"], name: "index_organizations_on_api_access_token", unique: true
    t.index ["name"], name: "index_organizations_on_name", unique: true
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
    t.decimal "elevation", precision: 10, scale: 6
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
    t.integer "likes_count"
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

  create_table "rock_bars", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.json "polyline"
    t.bigint "crag_id"
    t.bigint "crag_sector_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crag_id"], name: "index_rock_bars_on_crag_id"
    t.index ["crag_sector_id"], name: "index_rock_bars_on_crag_sector_id"
    t.index ["user_id"], name: "index_rock_bars_on_user_id"
  end

  create_table "searches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "index_name"
    t.bigint "index_id"
    t.string "collection"
    t.string "bucket"
    t.string "secondary_bucket"
    t.index ["bucket"], name: "index_searches_on_bucket"
    t.index ["collection"], name: "index_searches_on_collection"
    t.index ["index_id"], name: "index_searches_on_index_id"
    t.index ["index_name"], name: "index_searches_on_index_name"
    t.index ["secondary_bucket"], name: "index_searches_on_secondary_bucket"
  end

  create_table "stripe_checkout_sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "checkout_session_id"
    t.datetime "processed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["checkout_session_id"], name: "index_stripe_checkout_sessions_on_checkout_session_id"
  end

  create_table "subscribes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email"
    t.datetime "subscribed_at"
    t.integer "error"
    t.bigint "legacy_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "complained_at"
    t.index ["email"], name: "index_subscribes_on_email", unique: true
  end

  create_table "tick_lists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "crag_route_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["crag_route_id"], name: "index_tick_lists_on_crag_route_id"
    t.index ["user_id"], name: "index_tick_lists_on_user_id"
  end

  create_table "town_json_objects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "dist"
    t.bigint "town_id"
    t.json "json_object"
    t.datetime "version_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dist"], name: "index_town_json_objects_on_dist"
    t.index ["town_id"], name: "index_town_json_objects_on_town_id"
  end

  create_table "towns", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug_name"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "population"
    t.string "town_code", limit: 5
    t.string "zipcode", limit: 5
    t.bigint "department_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_towns_on_department_id"
    t.index ["latitude"], name: "index_towns_on_latitude"
    t.index ["longitude"], name: "index_towns_on_longitude"
    t.index ["name"], name: "index_towns_on_name"
    t.index ["slug_name"], name: "index_towns_on_slug_name", unique: true
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.date "date_of_birth"
    t.string "genre"
    t.text "description"
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
    t.integer "grade_max"
    t.integer "grade_min"
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
    t.integer "follows_count"
    t.string "uuid", limit: 36
    t.boolean "public_profile"
    t.boolean "public_outdoor_ascents"
    t.boolean "public_indoor_ascents"
    t.decimal "partner_latitude", precision: 10, scale: 6
    t.decimal "partner_longitude", precision: 10, scale: 6
    t.datetime "last_activity_at"
    t.datetime "partner_search_activated_at"
    t.datetime "last_partner_check_at"
    t.datetime "partner_notified_at"
    t.json "email_notifiable_list"
    t.string "ws_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
    t.index ["ws_token"], name: "index_users_on_ws_token", unique: true
  end

  create_table "versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at"
    t.text "object_changes", size: :long
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "videos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.string "video_service"
    t.string "url"
    t.text "embedded_code"
    t.bigint "user_id"
    t.string "viewable_type"
    t.bigint "viewable_id"
    t.integer "likes_count"
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
  add_foreign_key "championship_categories", "championships"
  add_foreign_key "championship_category_matches", "championship_categories"
  add_foreign_key "championship_category_matches", "contest_categories"
  add_foreign_key "championship_contests", "championships"
  add_foreign_key "championship_contests", "contests"
  add_foreign_key "championships", "gyms"
  add_foreign_key "contest_categories", "contests"
  add_foreign_key "contest_participant_ascents", "contest_participants"
  add_foreign_key "contest_participant_ascents", "contest_routes"
  add_foreign_key "contest_participant_steps", "contest_participants"
  add_foreign_key "contest_participant_steps", "contest_stage_steps"
  add_foreign_key "contest_participants", "contest_categories"
  add_foreign_key "contest_participants", "contest_waves"
  add_foreign_key "contest_participants", "users"
  add_foreign_key "contest_route_group_categories", "contest_categories"
  add_foreign_key "contest_route_group_categories", "contest_route_groups"
  add_foreign_key "contest_route_groups", "contest_stage_steps"
  add_foreign_key "contest_routes", "contest_route_groups"
  add_foreign_key "contest_routes", "gym_routes"
  add_foreign_key "contest_stage_steps", "contest_stages"
  add_foreign_key "contest_stages", "contests"
  add_foreign_key "contest_time_blocks", "contest_route_groups"
  add_foreign_key "contest_time_blocks", "contest_waves"
  add_foreign_key "contest_waves", "contests"
  add_foreign_key "contests", "gyms"
  add_foreign_key "gym_chain_administrators", "gym_chains"
  add_foreign_key "gym_chain_administrators", "users"
  add_foreign_key "gym_chain_gyms", "gym_chains"
  add_foreign_key "gym_chain_gyms", "gyms"
  add_foreign_key "gym_label_templates", "gyms"
  add_foreign_key "gym_levels", "gyms"
  add_foreign_key "gym_opening_sheets", "gyms"
  add_foreign_key "gym_options", "gyms"
  add_foreign_key "gym_three_d_assets", "gyms"
  add_foreign_key "gym_three_d_elements", "gym_spaces"
  add_foreign_key "gym_three_d_elements", "gym_three_d_assets"
  add_foreign_key "gym_three_d_elements", "gyms"
  add_foreign_key "gyms", "gym_billing_accounts"
  add_foreign_key "indoor_subscription_gyms", "gyms"
  add_foreign_key "indoor_subscription_gyms", "indoor_subscriptions"
  add_foreign_key "likes", "users"
end
