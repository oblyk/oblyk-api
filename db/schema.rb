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

ActiveRecord::Schema[8.1].define(version: 2026_08_22_095849) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alerts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "alert_type"
    t.bigint "alertable_id"
    t.string "alertable_type"
    t.datetime "alerted_at", precision: nil
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["alertable_type", "alertable_id"], name: "index_alerts_on_alertable_type_and_alertable_id"
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "approaches", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "approach_type"
    t.bigint "crag_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "from_park", default: true
    t.bigint "legacy_id"
    t.integer "length"
    t.json "path_metadata"
    t.json "polyline"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["crag_id"], name: "index_approaches_on_crag_id"
    t.index ["user_id"], name: "index_approaches_on_user_id"
  end

  create_table "area_crags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "area_id"
    t.bigint "crag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["area_id"], name: "index_area_crags_on_area_id"
    t.index ["crag_id", "area_id"], name: "index_area_crags_on_crag_id_and_area_id", unique: true
    t.index ["crag_id"], name: "index_area_crags_on_crag_id"
    t.index ["user_id"], name: "index_area_crags_on_user_id"
  end

  create_table "areas", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "comments_count"
    t.datetime "created_at", null: false
    t.bigint "legacy_id"
    t.string "name"
    t.bigint "photo_id"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["photo_id"], name: "index_areas_on_photo_id"
    t.index ["user_id"], name: "index_areas_on_user_id"
  end

  create_table "article_crags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "crag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_crags_on_article_id"
    t.index ["crag_id", "article_id"], name: "unique_crag_and_article_index", unique: true
    t.index ["crag_id"], name: "index_article_crags_on_crag_id"
  end

  create_table "article_guide_book_papers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "article_id"
    t.datetime "created_at", null: false
    t.bigint "guide_book_paper_id"
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_guide_book_papers_on_article_id"
    t.index ["guide_book_paper_id", "article_id"], name: "unique_guide_book_and_article_index", unique: true
    t.index ["guide_book_paper_id"], name: "index_article_guide_book_papers_on_guide_book_paper_id"
  end

  create_table "articles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "author_id"
    t.text "body"
    t.integer "comments_count"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "likes_count"
    t.string "name"
    t.integer "photos_count"
    t.datetime "published_at", precision: nil
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.integer "views"
    t.index ["author_id"], name: "index_articles_on_author_id"
  end

  create_table "ascent_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "ascent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["ascent_id"], name: "index_ascent_users_on_ascent_id"
    t.index ["user_id", "ascent_id"], name: "index_ascent_users_on_user_id_and_ascent_id", unique: true
    t.index ["user_id"], name: "index_ascent_users_on_user_id"
  end

  create_table "ascents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "ascent_status"
    t.integer "attempt"
    t.bigint "climbing_session_id"
    t.string "climbing_type"
    t.bigint "color_system_line_id"
    t.text "comment"
    t.integer "comments_count"
    t.bigint "crag_route_id"
    t.datetime "created_at", null: false
    t.integer "gym_grade_level"
    t.bigint "gym_id"
    t.bigint "gym_route_id"
    t.string "hardness_status"
    t.integer "height"
    t.bigint "legacy_id"
    t.text "max_grade_text"
    t.integer "max_grade_value"
    t.text "min_grade_text"
    t.integer "min_grade_value"
    t.integer "note"
    t.integer "points"
    t.boolean "private_comment"
    t.integer "quantity", default: 1
    t.date "released_at"
    t.string "roping_status"
    t.json "sections"
    t.integer "sections_count"
    t.string "type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["climbing_session_id"], name: "index_ascents_on_climbing_session_id"
    t.index ["color_system_line_id"], name: "index_ascents_on_color_system_line_id"
    t.index ["crag_route_id"], name: "index_ascents_on_crag_route_id"
    t.index ["created_at"], name: "index_ascents_on_created_at"
    t.index ["gym_id"], name: "index_ascents_on_gym_id"
    t.index ["gym_route_id"], name: "index_ascents_on_gym_route_id"
    t.index ["released_at"], name: "index_ascents_on_released_at"
    t.index ["user_id"], name: "index_ascents_on_user_id"
  end

  create_table "authors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "championship_categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "championship_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.index ["championship_id"], name: "index_championship_categories_on_championship_id"
  end

  create_table "championship_category_matches", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "championship_category_id"
    t.bigint "contest_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["championship_category_id"], name: "index_championship_category_matches_on_championship_category_id"
    t.index ["contest_category_id"], name: "index_championship_category_matches_on_contest_category_id"
  end

  create_table "championship_contests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "championship_id"
    t.bigint "contest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["championship_id"], name: "index_championship_contests_on_championship_id"
    t.index ["contest_id"], name: "index_championship_contests_on_contest_id"
  end

  create_table "championships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.string "combined_ranking_type"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "gym_id"
    t.string "name"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_championships_on_gym_id"
  end

  create_table "climbing_sessions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "session_date"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["session_date"], name: "index_climbing_sessions_on_session_date"
    t.index ["user_id"], name: "index_climbing_sessions_on_user_id"
  end

  create_table "color_system_lines", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "color_system_id"
    t.datetime "created_at", null: false
    t.string "hex_color"
    t.integer "order"
    t.datetime "updated_at", null: false
    t.index ["color_system_id"], name: "index_color_system_lines_on_color_system_id"
  end

  create_table "color_systems", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "colors_mark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["colors_mark"], name: "index_color_systems_on_colors_mark", unique: true
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.integer "comments_count"
    t.datetime "created_at", null: false
    t.bigint "legacy_id"
    t.integer "likes_count"
    t.datetime "moderated_at", precision: nil
    t.bigint "reply_to_comment_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["reply_to_comment_id"], name: "index_comments_on_reply_to_comment_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contest_categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "auto_distribute"
    t.integer "capacity"
    t.bigint "contest_id"
    t.integer "contest_participants_count"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "max_age"
    t.integer "min_age"
    t.string "name"
    t.integer "order"
    t.boolean "parity", default: false
    t.string "registration_obligation"
    t.string "slug_name"
    t.boolean "unisex"
    t.datetime "updated_at", null: false
    t.boolean "waveable"
    t.index ["contest_id"], name: "index_contest_categories_on_contest_id"
  end

  create_table "contest_judge_routes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.bigint "contest_judge_id", null: false
    t.bigint "contest_route_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_judge_routes_on_contest_id"
    t.index ["contest_judge_id"], name: "index_contest_judge_routes_on_contest_judge_id"
    t.index ["contest_route_id"], name: "index_contest_judge_routes_on_contest_route_id"
  end

  create_table "contest_judges", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "code"
    t.bigint "contest_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["contest_id"], name: "index_contest_judges_on_contest_id"
    t.index ["uuid"], name: "index_contest_judges_on_uuid"
  end

  create_table "contest_participant_ascents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.time "ascent_time", precision: 3
    t.bigint "contest_id"
    t.bigint "contest_participant_id"
    t.bigint "contest_route_id"
    t.integer "hold_number"
    t.boolean "hold_number_plus"
    t.boolean "realised"
    t.datetime "registered_at", precision: nil
    t.integer "top_attempt"
    t.integer "zone_1_attempt"
    t.integer "zone_2_attempt"
    t.index ["contest_id"], name: "index_contest_participant_ascents_on_contest_id"
    t.index ["contest_participant_id"], name: "index_contest_participant_ascents_on_contest_participant_id"
    t.index ["contest_route_id"], name: "index_contest_participant_ascents_on_contest_route_id"
  end

  create_table "contest_participant_steps", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.bigint "contest_participant_id"
    t.bigint "contest_stage_step_id"
    t.integer "ranking"
    t.index ["contest_id"], name: "index_contest_participant_steps_on_contest_id"
    t.index ["contest_participant_id"], name: "index_contest_participant_steps_on_contest_participant_id"
    t.index ["contest_stage_step_id"], name: "index_contest_participant_steps_on_contest_stage_step_id"
  end

  create_table "contest_participants", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "affiliation"
    t.bigint "contest_category_id"
    t.bigint "contest_id"
    t.bigint "contest_team_id"
    t.bigint "contest_wave_id"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email"
    t.string "first_name"
    t.string "genre"
    t.string "last_name"
    t.boolean "synchronise_with_ffme_contest"
    t.string "token"
    t.boolean "tombola_winner", default: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["contest_category_id"], name: "index_contest_participants_on_contest_category_id"
    t.index ["contest_id"], name: "index_contest_participants_on_contest_id"
    t.index ["contest_team_id"], name: "index_contest_participants_on_contest_team_id"
    t.index ["contest_wave_id"], name: "index_contest_participants_on_contest_wave_id"
    t.index ["token"], name: "index_contest_participants_on_token"
    t.index ["user_id"], name: "index_contest_participants_on_user_id"
  end

  create_table "contest_route_group_categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_category_id"
    t.bigint "contest_id"
    t.bigint "contest_route_group_id"
    t.index ["contest_category_id"], name: "index_contest_route_group_categories_on_contest_category_id"
    t.index ["contest_id"], name: "index_contest_route_group_categories_on_contest_id"
    t.index ["contest_route_group_id"], name: "index_contest_route_group_categories_on_contest_route_group_id"
  end

  create_table "contest_route_groups", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "additional_time", default: 20
    t.bigint "contest_id"
    t.bigint "contest_stage_step_id"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.time "end_time"
    t.string "genre_type"
    t.integer "number_participants_for_next_step"
    t.date "route_group_date"
    t.date "start_date"
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.boolean "waveable"
    t.index ["contest_id"], name: "index_contest_route_groups_on_contest_id"
    t.index ["contest_stage_step_id"], name: "index_contest_route_groups_on_contest_stage_step_id"
  end

  create_table "contest_routes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "additional_zone"
    t.bigint "contest_id"
    t.bigint "contest_route_group_id"
    t.datetime "created_at", null: false
    t.datetime "disabled_at", precision: nil
    t.integer "fixed_points"
    t.bigint "gym_route_id"
    t.string "name"
    t.integer "number"
    t.integer "number_of_holds"
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_routes_on_contest_id"
    t.index ["contest_route_group_id"], name: "index_contest_routes_on_contest_route_group_id"
    t.index ["gym_route_id"], name: "index_contest_routes_on_gym_route_id"
  end

  create_table "contest_stage_steps", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ascents_limit"
    t.bigint "contest_id"
    t.bigint "contest_stage_id"
    t.datetime "created_at", null: false
    t.integer "default_participants_for_next_step"
    t.string "name"
    t.string "ranking_type"
    t.boolean "self_reporting"
    t.string "slug_name"
    t.integer "step_order"
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_stage_steps_on_contest_id"
    t.index ["contest_stage_id"], name: "index_contest_stage_steps_on_contest_stage_id"
  end

  create_table "contest_stages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "climbing_type"
    t.bigint "contest_id"
    t.datetime "created_at", null: false
    t.string "default_ranking_type"
    t.text "description"
    t.string "name"
    t.date "stage_date"
    t.integer "stage_order"
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_stages_on_contest_id"
  end

  create_table "contest_teams", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "contest_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_teams_on_contest_id"
    t.index ["name", "contest_id"], name: "index_contest_teams_on_name_and_contest_id", unique: true
  end

  create_table "contest_time_blocks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "additional_time", default: 20
    t.bigint "contest_id"
    t.bigint "contest_route_group_id"
    t.bigint "contest_wave_id"
    t.date "end_date"
    t.time "end_time"
    t.date "start_date"
    t.time "start_time"
    t.index ["contest_id"], name: "index_contest_time_blocks_on_contest_id"
    t.index ["contest_route_group_id"], name: "index_contest_time_blocks_on_contest_route_group_id"
    t.index ["contest_wave_id"], name: "index_contest_time_blocks_on_contest_wave_id"
  end

  create_table "contest_waves", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "capacity"
    t.bigint "contest_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_contest_waves_on_contest_id"
  end

  create_table "contests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.boolean "authorise_public_subscription", default: true
    t.string "categorization_type"
    t.string "combined_ranking_type"
    t.integer "contest_participants_count"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.boolean "draft"
    t.date "end_date"
    t.bigint "gym_id"
    t.boolean "hide_results", default: false
    t.string "name"
    t.boolean "optional_gender", default: false
    t.integer "participant_per_team", default: 0
    t.boolean "private", default: false
    t.string "slug_name"
    t.date "start_date"
    t.datetime "subscription_closed_at", precision: nil
    t.date "subscription_end_date"
    t.date "subscription_start_date"
    t.boolean "team_contest", default: false
    t.integer "total_capacity"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_contests_on_gym_id"
  end

  create_table "conversation_messages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.bigint "conversation_id"
    t.datetime "created_at", null: false
    t.bigint "legacy_id"
    t.datetime "posted_at", precision: nil
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["conversation_id"], name: "index_conversation_messages_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_messages_on_user_id"
  end

  create_table "conversation_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conversation_id"
    t.datetime "created_at", null: false
    t.datetime "last_read_at", precision: nil
    t.bigint "legacy_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["conversation_id"], name: "index_conversation_users_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_users_on_user_id"
  end

  create_table "conversations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_message_at", precision: nil
    t.bigint "legacy_id"
    t.datetime "updated_at", null: false
  end

  create_table "countries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "code_country", limit: 5
    t.datetime "created_at", null: false
    t.json "geo_polygon"
    t.string "name"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_countries_on_name"
    t.index ["slug_name"], name: "index_countries_on_slug_name", unique: true
  end

  create_table "crag_routes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ascent_users_count", default: 0
    t.integer "ascents_count"
    t.string "climbing_type"
    t.integer "comments_count"
    t.bigint "crag_id"
    t.bigint "crag_sector_id"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.float "difficulty_appreciation"
    t.integer "height"
    t.string "incline_type"
    t.bigint "legacy_id"
    t.json "location"
    t.integer "max_bolt"
    t.text "max_grade_text"
    t.integer "max_grade_value"
    t.text "min_grade_text"
    t.integer "min_grade_value"
    t.string "name"
    t.float "note"
    t.integer "note_count"
    t.integer "open_year"
    t.string "opener"
    t.bigint "photo_id"
    t.integer "photos_count"
    t.string "reception_type"
    t.json "sections"
    t.integer "sections_count"
    t.string "slug_name"
    t.string "start_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "videos_count"
    t.json "votes"
    t.index ["crag_id"], name: "index_crag_routes_on_crag_id"
    t.index ["crag_sector_id"], name: "index_crag_routes_on_crag_sector_id"
    t.index ["created_at"], name: "index_crag_routes_on_created_at"
    t.index ["name"], name: "index_crag_routes_on_name"
    t.index ["photo_id"], name: "index_crag_routes_on_photo_id"
    t.index ["user_id"], name: "index_crag_routes_on_user_id"
  end

  create_table "crag_sectors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "ascent_users_count", default: 0
    t.integer "ascents_count", default: 0
    t.integer "comments_count"
    t.bigint "crag_id"
    t.integer "crag_routes_count"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.boolean "east"
    t.decimal "elevation", precision: 10, scale: 6
    t.decimal "latitude", precision: 10, scale: 6
    t.bigint "legacy_id"
    t.json "location"
    t.decimal "longitude", precision: 10, scale: 6
    t.string "max_grade_text"
    t.integer "max_grade_value"
    t.string "min_grade_text"
    t.integer "min_grade_value"
    t.string "name"
    t.boolean "north"
    t.boolean "north_east"
    t.boolean "north_west"
    t.bigint "photo_id"
    t.integer "photos_count"
    t.string "rain"
    t.string "slug_name"
    t.boolean "south"
    t.boolean "south_east"
    t.boolean "south_west"
    t.string "sun"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "west"
    t.index ["crag_id"], name: "index_crag_sectors_on_crag_id"
    t.index ["name"], name: "index_crag_sectors_on_name"
    t.index ["photo_id"], name: "index_crag_sectors_on_photo_id"
    t.index ["user_id"], name: "index_crag_sectors_on_user_id"
  end

  create_table "crags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "aid_climbing", default: false
    t.integer "articles_count"
    t.integer "ascent_users_count", default: 0
    t.integer "ascents_count", default: 0
    t.boolean "autumn"
    t.boolean "bouldering", default: false
    t.string "city"
    t.string "code_country"
    t.integer "comments_count"
    t.string "country"
    t.integer "crag_routes_count"
    t.datetime "created_at", null: false
    t.boolean "deep_water", default: false
    t.datetime "deleted_at", precision: nil
    t.bigint "department_id"
    t.boolean "east"
    t.decimal "elevation", precision: 10, scale: 6
    t.integer "follows_count"
    t.integer "grade_protection_level", default: 1
    t.decimal "latitude", precision: 10, scale: 6
    t.bigint "legacy_id"
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "max_approach_time"
    t.string "max_grade_text"
    t.integer "max_grade_value"
    t.integer "min_approach_time"
    t.string "min_grade_text"
    t.integer "min_grade_value"
    t.boolean "multi_pitch", default: false
    t.string "name"
    t.boolean "north"
    t.boolean "north_east"
    t.boolean "north_west"
    t.bigint "photo_id"
    t.integer "photos_count"
    t.string "rain"
    t.string "region"
    t.json "rocks"
    t.string "slug_name"
    t.boolean "south"
    t.boolean "south_east"
    t.boolean "south_west"
    t.boolean "sport_climbing", default: false
    t.boolean "spring"
    t.boolean "summer"
    t.string "sun"
    t.boolean "trad_climbing", default: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "via_ferrata", default: false
    t.integer "videos_count"
    t.boolean "west"
    t.boolean "winter"
    t.index ["created_at"], name: "index_crags_on_created_at"
    t.index ["department_id"], name: "index_crags_on_department_id"
    t.index ["name"], name: "index_crags_on_name"
    t.index ["photo_id"], name: "index_crags_on_photo_id"
    t.index ["user_id"], name: "index_crags_on_user_id"
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.string "department_number", limit: 5
    t.json "geo_polygon"
    t.string "in_sentence_prefix_type"
    t.string "name"
    t.string "name_prefix_type"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_departments_on_country_id"
    t.index ["department_number"], name: "index_departments_on_department_number"
    t.index ["name"], name: "index_departments_on_name"
    t.index ["slug_name"], name: "index_departments_on_slug_name", unique: true
  end

  create_table "ffme_contests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "contact_email"
    t.string "contact_phone"
    t.bigint "contest_id"
    t.string "contest_type"
    t.datetime "created_at", null: false
    t.string "description", limit: 2048
    t.date "end_date"
    t.bigint "external_ffme_contest_id"
    t.string "name"
    t.date "results_send_at"
    t.date "start_date"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_ffme_contests_on_contest_id"
  end

  create_table "follows", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "accepted_at", precision: nil
    t.datetime "created_at", null: false
    t.bigint "followable_id"
    t.string "followable_type"
    t.bigint "legacy_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "views", default: 0
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "guide_book_paper_crags", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "crag_id"
    t.datetime "created_at", null: false
    t.bigint "guide_book_paper_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["crag_id", "guide_book_paper_id"], name: "index_guide_book_paper_crags_on_crag_id_and_guide_book_paper_id", unique: true
    t.index ["crag_id"], name: "index_guide_book_paper_crags_on_crag_id"
    t.index ["guide_book_paper_id"], name: "index_guide_book_paper_crags_on_guide_book_paper_id"
    t.index ["user_id"], name: "index_guide_book_paper_crags_on_user_id"
  end

  create_table "guide_book_paper_questions", charset: "utf8mb3", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", null: false
    t.bigint "guide_book_paper_id"
    t.text "question"
    t.datetime "updated_at", null: false
    t.index ["guide_book_paper_id"], name: "index_guide_book_paper_questions_on_guide_book_paper_id"
  end

  create_table "guide_book_papers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "articles_count"
    t.string "author"
    t.integer "comments_count"
    t.datetime "created_at", null: false
    t.string "ean"
    t.string "editor"
    t.integer "follows_count"
    t.string "funding_status"
    t.bigint "legacy_id"
    t.string "name"
    t.bigint "next_guide_book_paper_id"
    t.integer "number_of_page"
    t.integer "price_cents"
    t.integer "publication_year"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "vc_reference"
    t.integer "weight"
    t.index ["created_at"], name: "index_guide_book_papers_on_created_at"
    t.index ["next_guide_book_paper_id"], name: "index_guide_book_papers_on_next_guide_book_paper_id"
    t.index ["user_id"], name: "index_guide_book_papers_on_user_id"
  end

  create_table "guide_book_pdfs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "author"
    t.bigint "crag_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "legacy_id"
    t.string "name"
    t.integer "publication_year"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["crag_id"], name: "index_guide_book_pdfs_on_crag_id"
    t.index ["created_at"], name: "index_guide_book_pdfs_on_created_at"
    t.index ["user_id"], name: "index_guide_book_pdfs_on_user_id"
  end

  create_table "guide_book_webs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "crag_id"
    t.datetime "created_at", null: false
    t.bigint "legacy_id"
    t.string "name"
    t.integer "publication_year"
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id"
    t.index ["crag_id"], name: "index_guide_book_webs_on_crag_id"
    t.index ["created_at"], name: "index_guide_book_webs_on_created_at"
    t.index ["user_id"], name: "index_guide_book_webs_on_user_id"
  end

  create_table "gym_administration_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.bigint "gym_id"
    t.text "justification"
    t.string "last_name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["gym_id"], name: "index_gym_administration_requests_on_gym_id"
    t.index ["user_id"], name: "index_gym_administration_requests_on_user_id"
  end

  create_table "gym_administrators", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "email_report", default: true
    t.bigint "gym_id"
    t.datetime "last_comment_feed_read_at", precision: nil
    t.datetime "last_follower_feed_read_at", precision: nil
    t.datetime "last_video_feed_read_at", precision: nil
    t.string "requested_email"
    t.json "roles"
    t.boolean "subscribe_to_comment_feed"
    t.boolean "subscribe_to_follower_feed"
    t.boolean "subscribe_to_video_feed"
    t.bigint "user_id"
    t.index ["gym_id"], name: "index_gym_administrators_on_gym_id"
    t.index ["user_id"], name: "index_gym_administrators_on_user_id"
  end

  create_table "gym_billing_accounts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_stripe_id"
    t.string "email"
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["uuid"], name: "index_gym_billing_accounts_on_uuid"
  end

  create_table "gym_chain_administrators", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "gym_chain_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["gym_chain_id"], name: "index_gym_chain_administrators_on_gym_chain_id"
    t.index ["user_id"], name: "index_gym_chain_administrators_on_user_id"
  end

  create_table "gym_chain_gyms", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "gym_chain_id"
    t.bigint "gym_id"
    t.datetime "updated_at", null: false
    t.index ["gym_chain_id"], name: "index_gym_chain_gyms_on_gym_chain_id"
    t.index ["gym_id"], name: "index_gym_chain_gyms_on_gym_id"
  end

  create_table "gym_chains", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "api_access_token"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.boolean "public_chain"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.index ["api_access_token"], name: "index_gym_chains_on_api_access_token", unique: true
    t.index ["slug_name"], name: "index_gym_chains_on_slug_name", unique: true
  end

  create_table "gym_climbing_styles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "climbing_type"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "deactivated_at", precision: nil
    t.bigint "gym_id"
    t.string "style"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_gym_climbing_styles_on_gym_id"
  end

  create_table "gym_label_templates", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.json "border_style"
    t.datetime "created_at", null: false
    t.boolean "display_anchor"
    t.boolean "display_climbing_style"
    t.boolean "display_description"
    t.boolean "display_grade"
    t.boolean "display_name"
    t.boolean "display_opened_at"
    t.boolean "display_openers"
    t.boolean "display_points"
    t.boolean "display_tag_and_hold"
    t.string "font_family"
    t.json "footer_options"
    t.string "grade_style"
    t.bigint "gym_id"
    t.json "header_options"
    t.string "label_arrangement"
    t.string "label_direction"
    t.json "label_options"
    t.json "layout_options"
    t.string "name"
    t.string "page_direction"
    t.string "page_format"
    t.string "qr_code_position"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_gym_label_templates_on_gym_id"
  end

  create_table "gym_levels", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "climbing_type"
    t.boolean "enabled", default: true
    t.string "grade_system"
    t.bigint "gym_id"
    t.string "level_representation"
    t.json "levels"
    t.boolean "sub_level_enabled", default: false
    t.integer "sub_level_max"
    t.index ["gym_id", "climbing_type"], name: "index_gym_levels_on_gym_id_and_climbing_type", unique: true
    t.index ["gym_id"], name: "index_gym_levels_on_gym_id"
  end

  create_table "gym_openers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deactivated_at", precision: nil
    t.string "email"
    t.string "first_name"
    t.bigint "gym_id"
    t.string "last_name"
    t.string "name"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["gym_id"], name: "index_gym_openers_on_gym_id"
    t.index ["user_id"], name: "index_gym_openers_on_user_id"
  end

  create_table "gym_opening_sheets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "gym_id"
    t.integer "number_of_columns"
    t.json "row_json"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_gym_opening_sheets_on_gym_id"
  end

  create_table "gym_options", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.bigint "gym_id"
    t.string "option_type"
    t.integer "remaining_unit"
    t.date "start_date"
    t.boolean "unlimited_unit"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_gym_options_on_gym_id"
  end

  create_table "gym_route_covers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gym_route_openers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "gym_opener_id"
    t.bigint "gym_route_id"
    t.datetime "updated_at", null: false
    t.index ["gym_opener_id"], name: "index_gym_route_openers_on_gym_opener_id"
    t.index ["gym_route_id"], name: "index_gym_route_openers_on_gym_route_id"
  end

  create_table "gym_routes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "all_comments_count", default: 0
    t.integer "anchor_number"
    t.datetime "archived_at", precision: nil
    t.integer "ascents_count"
    t.string "climbing_type"
    t.integer "comments_count"
    t.datetime "created_at", null: false
    t.text "description"
    t.float "difficulty_appreciation"
    t.datetime "dismounted_at", precision: nil
    t.bigint "gym_route_cover_id"
    t.bigint "gym_sector_id"
    t.integer "height"
    t.json "hold_colors"
    t.bigint "legacy_id"
    t.string "level_color"
    t.integer "level_index"
    t.integer "level_length"
    t.integer "likes_count"
    t.text "max_grade_text"
    t.integer "max_grade_value"
    t.text "min_grade_text"
    t.integer "min_grade_value"
    t.string "name"
    t.integer "note"
    t.integer "note_count"
    t.date "opened_at"
    t.string "openers"
    t.integer "points"
    t.text "polyline"
    t.json "sections"
    t.integer "sections_count"
    t.integer "sub_level"
    t.integer "sub_level_max"
    t.json "tag_colors"
    t.json "thumbnail_position"
    t.datetime "updated_at", null: false
    t.integer "videos_count"
    t.json "votes"
    t.index ["created_at"], name: "index_gym_routes_on_created_at"
    t.index ["gym_route_cover_id"], name: "index_gym_routes_on_gym_route_cover_id"
    t.index ["gym_sector_id"], name: "index_gym_routes_on_gym_sector_id"
  end

  create_table "gym_sectors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "average_opening_time"
    t.boolean "can_be_more_than_one_pitch", default: false
    t.string "category_name"
    t.string "climbing_type"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.float "developed_metre"
    t.string "group_sector_name"
    t.bigint "gym_space_id"
    t.integer "height"
    t.bigint "legacy_id"
    t.float "linear_metre"
    t.integer "max_anchor_number"
    t.integer "min_anchor_number"
    t.string "name"
    t.integer "order", default: 0
    t.text "polygon"
    t.decimal "three_d_elevated", precision: 10, scale: 6, default: "0.0"
    t.decimal "three_d_height", precision: 10, scale: 6
    t.json "three_d_label_options"
    t.json "three_d_path"
    t.datetime "updated_at", null: false
    t.index ["gym_space_id"], name: "index_gym_sectors_on_gym_space_id"
  end

  create_table "gym_space_groups", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "gym_id"
    t.string "name"
    t.integer "order"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_gym_space_groups_on_gym_id"
  end

  create_table "gym_spaces", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "anchor"
    t.datetime "archived_at", precision: nil
    t.string "climbing_type"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.boolean "draft", default: false
    t.bigint "gym_id"
    t.bigint "gym_space_group_id"
    t.decimal "latitude", precision: 10, scale: 6
    t.bigint "legacy_id"
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name"
    t.integer "order"
    t.string "representation_type", default: "2d_picture"
    t.integer "scheme_height"
    t.integer "scheme_width"
    t.string "sectors_color"
    t.string "slug_name"
    t.text "svg_sectors"
    t.json "three_d_camera_position"
    t.json "three_d_label_options"
    t.json "three_d_parameters"
    t.json "three_d_position"
    t.json "three_d_rotation"
    t.decimal "three_d_scale", precision: 10, scale: 6, default: "1.0"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_gym_spaces_on_gym_id"
    t.index ["gym_space_group_id"], name: "index_gym_spaces_on_gym_space_group_id"
  end

  create_table "gym_three_d_assets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "gym_id"
    t.string "name"
    t.string "slug_name"
    t.json "three_d_parameters"
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_gym_three_d_assets_on_gym_id"
  end

  create_table "gym_three_d_elements", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "gym_id"
    t.bigint "gym_space_id"
    t.bigint "gym_three_d_asset_id"
    t.text "message"
    t.json "three_d_position"
    t.json "three_d_rotation"
    t.decimal "three_d_scale", precision: 10, scale: 6, default: "1.0"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["gym_id"], name: "index_gym_three_d_elements_on_gym_id"
    t.index ["gym_space_id"], name: "index_gym_three_d_elements_on_gym_space_id"
    t.index ["gym_three_d_asset_id"], name: "index_gym_three_d_elements_on_gym_three_d_asset_id"
  end

  create_table "gyms", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address"
    t.json "app_paths"
    t.json "ascents_multiplier"
    t.datetime "assigned_at", precision: nil
    t.string "big_city"
    t.string "boulder_ranking"
    t.boolean "bouldering"
    t.string "city"
    t.string "code_country"
    t.integer "comments_count"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.bigint "department_id"
    t.text "description"
    t.string "email"
    t.integer "follows_count"
    t.boolean "fun_climbing"
    t.bigint "gym_billing_account_id"
    t.string "gym_type"
    t.string "insee_code"
    t.decimal "latitude", precision: 10, scale: 6
    t.bigint "legacy_id"
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name"
    t.boolean "pan"
    t.string "pan_ranking"
    t.string "phone_number"
    t.string "plan"
    t.datetime "plan_end_at", precision: nil
    t.datetime "plan_start_at", precision: nil
    t.string "postal_code"
    t.boolean "public_guide_book", default: false
    t.string "region"
    t.string "representation_type", default: "2d_picture"
    t.string "slug_name"
    t.boolean "sport_climbing"
    t.string "sport_climbing_ranking"
    t.json "three_d_camera_position"
    t.boolean "training_space"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "videos_count"
    t.string "web_site"
    t.index ["created_at"], name: "index_gyms_on_created_at"
    t.index ["department_id"], name: "index_gyms_on_department_id"
    t.index ["gym_billing_account_id"], name: "index_gyms_on_gym_billing_account_id"
    t.index ["name"], name: "index_gyms_on_name"
    t.index ["user_id"], name: "index_gyms_on_user_id"
  end

  create_table "indoor_subscription_gyms", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "gym_id"
    t.bigint "indoor_subscription_id"
    t.index ["gym_id"], name: "index_indoor_subscription_gyms_on_gym_id"
    t.index ["indoor_subscription_id"], name: "index_indoor_subscription_gyms_on_indoor_subscription_id"
  end

  create_table "indoor_subscription_products", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "for_gym_type"
    t.integer "month_by_occurrence"
    t.integer "order"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "USD", null: false
    t.string "product_stripe_id"
    t.boolean "recommended"
    t.string "reference"
    t.datetime "updated_at", null: false
  end

  create_table "indoor_subscriptions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "cancelled_at", precision: nil
    t.datetime "created_at", null: false
    t.date "end_date"
    t.string "for_gym_type"
    t.integer "month_by_occurrence"
    t.string "payment_link"
    t.string "payment_link_stipe_id"
    t.string "payment_status"
    t.date "start_date"
    t.string "subscription_stripe_id"
    t.date "trial_end_date"
    t.datetime "updated_at", null: false
  end

  create_table "ip_black_lists", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "block_count"
    t.datetime "block_expired_at", precision: nil
    t.datetime "blocked_at", precision: nil
    t.string "ip"
    t.text "params_sent"
    t.index ["block_expired_at"], name: "index_ip_black_lists_on_block_expired_at"
    t.index ["ip"], name: "index_ip_black_lists_on_ip"
  end

  create_table "likes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "likeable_id"
    t.string "likeable_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "links", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "legacy_id"
    t.bigint "linkable_id"
    t.string "linkable_type"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id"
    t.index ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id"
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "localities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "code_country"
    t.datetime "created_at", null: false
    t.integer "distinct_users_count"
    t.decimal "latitude", precision: 10, scale: 6
    t.integer "local_sharing_users_count"
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name"
    t.integer "partner_search_users_count"
    t.string "region"
    t.datetime "updated_at", null: false
    t.index ["latitude"], name: "index_localities_on_latitude"
    t.index ["longitude"], name: "index_localities_on_longitude"
  end

  create_table "locality_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deactivated_at", precision: nil
    t.text "description"
    t.boolean "local_sharing"
    t.bigint "locality_id"
    t.boolean "partner_search"
    t.integer "radius"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["locality_id"], name: "index_locality_users_on_locality_id"
    t.index ["user_id"], name: "index_locality_users_on_user_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "email_notification_sent_at", precision: nil
    t.bigint "notifiable_id"
    t.string "notifiable_type"
    t.string "notification_type"
    t.datetime "posted_at", precision: nil
    t.datetime "read_at", precision: nil
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["posted_at"], name: "index_notifications_on_posted_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organization_users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organization_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["organization_id"], name: "index_organization_users_on_organization_id"
    t.index ["user_id"], name: "index_organization_users_on_user_id"
  end

  create_table "organizations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address"
    t.string "api_access_token"
    t.string "api_usage_type"
    t.string "city"
    t.string "company_registration_number"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.string "email"
    t.string "name"
    t.string "phone"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.string "website"
    t.string "zipcode"
    t.index ["api_access_token"], name: "index_organizations_on_api_access_token", unique: true
    t.index ["name"], name: "index_organizations_on_name", unique: true
  end

  create_table "parks", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "crag_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "elevation", precision: 10, scale: 6
    t.decimal "latitude", precision: 10, scale: 6
    t.bigint "legacy_id"
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["crag_id"], name: "index_parks_on_crag_id"
    t.index ["user_id"], name: "index_parks_on_user_id"
  end

  create_table "photos", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "alt"
    t.boolean "copyright_by"
    t.boolean "copyright_nc"
    t.boolean "copyright_nd"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "exif_make"
    t.string "exif_model"
    t.bigint "illustrable_id"
    t.string "illustrable_type"
    t.bigint "legacy_id"
    t.integer "likes_count"
    t.datetime "posted_at", precision: nil
    t.string "source"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["created_at"], name: "index_photos_on_created_at"
    t.index ["illustrable_type", "illustrable_id"], name: "index_photos_on_illustrable_type_and_illustrable_id"
    t.index ["user_id"], name: "index_photos_on_user_id"
  end

  create_table "place_of_sales", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "code_country"
    t.string "country"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "guide_book_paper_id"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name"
    t.string "postal_code"
    t.string "region"
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id"
    t.index ["guide_book_paper_id"], name: "index_place_of_sales_on_guide_book_paper_id"
    t.index ["user_id"], name: "index_place_of_sales_on_user_id"
  end

  create_table "publication_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "attachable_id"
    t.string "attachable_type"
    t.bigint "publication_id"
    t.index ["attachable_type", "attachable_id"], name: "index_publications_attachments_on_attachable_type_and_id"
    t.index ["publication_id"], name: "index_publication_attachments_on_publication_id"
  end

  create_table "publication_views", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "publication_id"
    t.bigint "user_id"
    t.datetime "viewed_at", precision: nil
    t.index ["publication_id"], name: "index_publication_views_on_publication_id"
    t.index ["user_id", "publication_id"], name: "index_publication_views_on_user_id_and_publication_id", unique: true
    t.index ["user_id"], name: "index_publication_views_on_user_id"
  end

  create_table "publications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.json "attachable_types_count"
    t.integer "attachables_count"
    t.bigint "author_id"
    t.text "body"
    t.integer "comments_count", default: 0
    t.datetime "created_at", null: false
    t.boolean "generated", default: false
    t.datetime "last_updated_at", precision: nil
    t.decimal "latitude", precision: 10, scale: 6
    t.integer "likes_count", default: 0
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "pined_at", precision: nil
    t.bigint "publishable_id"
    t.string "publishable_subject"
    t.string "publishable_type"
    t.datetime "published_at", precision: nil
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_publications_on_author_id"
    t.index ["latitude"], name: "index_publications_on_latitude"
    t.index ["longitude"], name: "index_publications_on_longitude"
    t.index ["pined_at"], name: "index_publications_on_pined_at"
    t.index ["publishable_type", "publishable_id"], name: "index_publications_on_publishable_type_and_publishable_id"
    t.index ["published_at"], name: "index_publications_on_published_at"
  end

  create_table "refresh_tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id"
    t.index ["token"], name: "index_refresh_tokens_on_token"
    t.index ["user_agent"], name: "index_refresh_tokens_on_user_agent"
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "reports", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "processed_at", precision: nil
    t.string "report_from_url"
    t.bigint "reportable_id"
    t.string "reportable_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "rock_bars", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "crag_id"
    t.bigint "crag_sector_id"
    t.datetime "created_at", null: false
    t.json "polyline"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["crag_id"], name: "index_rock_bars_on_crag_id"
    t.index ["crag_sector_id"], name: "index_rock_bars_on_crag_sector_id"
    t.index ["user_id"], name: "index_rock_bars_on_user_id"
  end

  create_table "stripe_checkout_sessions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "checkout_session_id"
    t.datetime "created_at", null: false
    t.datetime "processed_at", precision: nil
    t.datetime "updated_at", null: false
    t.index ["checkout_session_id"], name: "index_stripe_checkout_sessions_on_checkout_session_id"
  end

  create_table "subscribes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "complained_at", precision: nil
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "error"
    t.bigint "legacy_id"
    t.datetime "subscribed_at", precision: nil
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subscribes_on_email", unique: true
  end

  create_table "tick_lists", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "crag_route_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["crag_route_id"], name: "index_tick_lists_on_crag_route_id"
    t.index ["user_id"], name: "index_tick_lists_on_user_id"
  end

  create_table "town_json_objects", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "dist"
    t.json "json_object"
    t.bigint "town_id"
    t.datetime "updated_at", null: false
    t.datetime "version_date", precision: nil
    t.index ["dist"], name: "index_town_json_objects_on_dist"
    t.index ["town_id"], name: "index_town_json_objects_on_town_id"
  end

  create_table "towns", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "department_id"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "name"
    t.integer "population"
    t.string "slug_name"
    t.string "town_code", limit: 5
    t.datetime "updated_at", null: false
    t.string "zipcode", limit: 5
    t.index ["department_id"], name: "index_towns_on_department_id"
    t.index ["latitude"], name: "index_towns_on_latitude"
    t.index ["longitude"], name: "index_towns_on_longitude"
    t.index ["name"], name: "index_towns_on_name"
    t.index ["slug_name"], name: "index_towns_on_slug_name", unique: true
  end

  create_table "user_applications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ffme_licence_number"
    t.json "meta_data"
    t.string "status"
    t.string "type"
    t.datetime "updated_at", null: false
    t.string "user_application_id"
    t.bigint "user_id"
    t.index ["type", "user_id"], name: "index_user_applications_on_type_and_user_id", unique: true
    t.index ["user_application_id"], name: "index_user_applications_on_user_application_id"
    t.index ["user_id"], name: "index_user_applications_on_user_id"
  end

  create_table "user_crag_declarations", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "crag_id"
    t.datetime "created_at", null: false
    t.string "declaration_system"
    t.datetime "declared_at"
    t.integer "equivalent_level"
    t.bigint "guide_book_paper_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["crag_id", "user_id"], name: "index_user_crag_declarations_on_crag_id_and_user_id", unique: true
    t.index ["crag_id"], name: "index_user_crag_declarations_on_crag_id"
    t.index ["guide_book_paper_id"], name: "index_user_crag_declarations_on_guide_book_paper_id"
    t.index ["user_id"], name: "index_user_crag_declarations_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "aid_climbing", default: false
    t.boolean "bouldering", default: false
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.boolean "deep_water", default: false
    t.datetime "deleted_at", precision: nil
    t.text "description"
    t.string "email", null: false
    t.json "email_notifiable_list"
    t.string "first_name", null: false
    t.integer "follows_count"
    t.string "genre"
    t.integer "grade_max"
    t.integer "grade_min"
    t.string "language", default: "fr"
    t.datetime "last_activity_at", precision: nil
    t.string "last_name"
    t.datetime "last_partner_check_at", precision: nil
    t.decimal "latitude", precision: 10, scale: 6
    t.bigint "legacy_id"
    t.string "localization"
    t.decimal "longitude", precision: 10, scale: 6
    t.boolean "multi_pitch", default: false
    t.datetime "newsletter_accepted_at", precision: nil
    t.boolean "pan", default: false
    t.decimal "partner_latitude", precision: 10, scale: 6
    t.decimal "partner_longitude", precision: 10, scale: 6
    t.datetime "partner_notified_at", precision: nil
    t.boolean "partner_search"
    t.datetime "partner_search_activated_at", precision: nil
    t.string "password_digest", null: false
    t.boolean "public_indoor_ascents"
    t.boolean "public_outdoor_ascents"
    t.boolean "public_profile"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expired_at", precision: nil
    t.string "slug_name"
    t.boolean "sport_climbing", default: false
    t.boolean "super_admin", default: false
    t.boolean "trad_climbing", default: false
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 36
    t.boolean "via_ferrata", default: false
    t.string "ws_token"
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
    t.index ["ws_token"], name: "index_users_on_ws_token", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", limit: 191, null: false
    t.text "object", size: :long
    t.text "object_changes", size: :long
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "videos", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.text "embedded_code"
    t.bigint "legacy_id"
    t.integer "likes_count"
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id"
    t.string "video_service"
    t.bigint "viewable_id"
    t.string "viewable_type"
    t.index ["created_at"], name: "index_videos_on_created_at"
    t.index ["user_id"], name: "index_videos_on_user_id"
    t.index ["viewable_type", "viewable_id"], name: "index_videos_on_viewable_type_and_viewable_id"
  end

  create_table "words", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "definition"
    t.bigint "legacy_id"
    t.string "name"
    t.string "slug_name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["name"], name: "index_words_on_name", unique: true
    t.index ["user_id"], name: "index_words_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "championship_categories", "championships"
  add_foreign_key "championship_category_matches", "championship_categories"
  add_foreign_key "championship_category_matches", "contest_categories"
  add_foreign_key "championship_contests", "championships"
  add_foreign_key "championship_contests", "contests"
  add_foreign_key "championships", "gyms"
  add_foreign_key "contest_categories", "contests"
  add_foreign_key "contest_judge_routes", "contest_judges"
  add_foreign_key "contest_judge_routes", "contest_routes"
  add_foreign_key "contest_judges", "contests"
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
  add_foreign_key "ffme_contests", "contests"
  add_foreign_key "guide_book_paper_questions", "guide_book_papers"
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
  add_foreign_key "publication_attachments", "publications"
  add_foreign_key "publication_views", "publications"
  add_foreign_key "publication_views", "users"
  add_foreign_key "publications", "users", column: "author_id"
  add_foreign_key "user_applications", "users"
  add_foreign_key "user_crag_declarations", "crags"
  add_foreign_key "user_crag_declarations", "guide_book_papers"
  add_foreign_key "user_crag_declarations", "users"
end
