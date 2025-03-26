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

ActiveRecord::Schema[8.0].define(version: 2025_03_26_133734) do
  create_table "active_storage_attachments", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_messages", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "token"
    t.text "to"
    t.integer "user_id"
    t.string "user_type"
    t.string "mailer"
    t.text "subject"
    t.timestamp "sent_at"
    t.timestamp "opened_at"
    t.timestamp "clicked_at"
    t.index ["token"], name: "index_ahoy_messages_on_token"
    t.index ["user_id", "user_type"], name: "index_ahoy_messages_on_user_id_and_user_type"
  end

  create_table "assessments", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.datetime "end_date", precision: nil
    t.datetime "start_date", precision: nil
    t.integer "project_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "instructor_updated", default: false, null: false
    t.boolean "active", default: true, null: false
    t.index ["project_id"], name: "index_assessments_on_project_id"
  end

  create_table "assignments", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "start_date", precision: nil, null: false
    t.datetime "end_date", precision: nil, null: false
    t.bigint "rubric_id"
    t.boolean "group_enabled", default: false, null: false
    t.integer "course_id", null: false
    t.integer "project_id"
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "passing", default: 65
    t.string "anon_name"
    t.string "anon_description"
    t.boolean "file_sub", default: false, null: false
    t.boolean "link_sub", default: false, null: false
    t.boolean "text_sub", default: true, null: false
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["project_id"], name: "index_assignments_on_project_id"
    t.index ["rubric_id"], name: "index_assignments_on_rubric_id"
  end

  create_table "behaviors", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name_en"
    t.text "description_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name_ko"
    t.text "description_ko"
    t.boolean "needs_detail", default: false, null: false
    t.index ["name_en"], name: "index_behaviors_on_name_en", unique: true
  end

  create_table "bingo_boards", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "bingo_game_id"
    t.integer "user_id"
    t.integer "winner"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "win_claimed"
    t.integer "iteration", default: 0
    t.integer "board_type", default: 0
    t.integer "performance"
    t.index ["bingo_game_id"], name: "index_bingo_boards_on_bingo_game_id"
    t.index ["user_id"], name: "index_bingo_boards_on_user_id"
  end

  create_table "bingo_cells", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "bingo_board_id"
    t.integer "concept_id"
    t.integer "row"
    t.integer "column"
    t.boolean "selected"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "indeks"
    t.integer "candidate_id"
    t.index ["bingo_board_id"], name: "index_bingo_cells_on_bingo_board_id"
    t.index ["candidate_id"], name: "index_bingo_cells_on_candidate_id"
    t.index ["concept_id"], name: "index_bingo_cells_on_concept_id"
  end

  create_table "bingo_games", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "topic"
    t.text "description"
    t.string "link"
    t.string "source"
    t.boolean "group_option"
    t.integer "individual_count"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: false
    t.integer "course_id"
    t.integer "project_id"
    t.integer "lead_time", default: 3
    t.integer "group_discount"
    t.boolean "reviewed"
    t.boolean "instructor_notified", default: false, null: false
    t.boolean "students_notified", default: false, null: false
    t.string "anon_topic"
    t.integer "size", default: 5
    t.index ["course_id"], name: "index_bingo_games_on_course_id"
    t.index ["project_id"], name: "index_bingo_games_on_project_id"
  end

  create_table "candidate_feedbacks", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name_ko"
    t.text "definition_en"
    t.text "definition_ko"
    t.integer "credit"
    t.integer "critique", default: 3, null: false
    t.index ["name_en"], name: "index_candidate_feedbacks_on_name_en", unique: true
  end

  create_table "candidate_lists", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.boolean "is_group"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "bingo_game_id"
    t.boolean "group_requested"
    t.integer "cached_performance"
    t.boolean "archived", default: false, null: false
    t.integer "contributor_count", default: 1, null: false
    t.integer "current_candidate_list_id"
    t.integer "candidates_count", default: 0, null: false
    t.index ["bingo_game_id"], name: "index_candidate_lists_on_bingo_game_id"
    t.index ["current_candidate_list_id"], name: "fk_rails_de17bb0877"
    t.index ["group_id"], name: "index_candidate_lists_on_group_id"
    t.index ["user_id"], name: "index_candidate_lists_on_user_id"
  end

  create_table "candidates", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.text "definition"
    t.integer "candidate_list_id"
    t.integer "candidate_feedback_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "concept_id"
    t.string "term"
    t.integer "user_id", null: false
    t.string "filtered_consistent"
    t.index ["candidate_feedback_id"], name: "index_candidates_on_candidate_feedback_id"
    t.index ["candidate_list_id"], name: "index_candidates_on_candidate_list_id"
    t.index ["concept_id"], name: "index_candidates_on_concept_id"
    t.index ["definition"], name: "index_candidates_on_definition", length: 2
    t.index ["term"], name: "index_candidates_on_term", length: 2
    t.index ["user_id"], name: "index_candidates_on_user_id"
  end

  create_table "cip_codes", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "gov_code"
    t.string "name_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name_ko"
    t.index ["gov_code"], name: "index_cip_codes_on_gov_code", unique: true
  end

  create_table "concepts", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "candidates_count", default: 0, null: false
    t.integer "courses_count", default: 0, null: false
    t.integer "bingo_games_count", default: 0, null: false
    t.index ["name"], name: "concept_fulltext", type: :fulltext
    t.index ["name"], name: "index_concepts_on_name", unique: true
  end

  create_table "consent_forms", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "form_text_en"
    t.date "start_date"
    t.date "end_date"
    t.boolean "active", default: false, null: false
    t.text "form_text_ko"
    t.integer "courses_count", default: 0, null: false
    t.index ["user_id"], name: "index_consent_forms_on_user_id"
  end

  create_table "consent_logs", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.boolean "accepted"
    t.integer "consent_form_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "presented"
    t.index ["consent_form_id"], name: "index_consent_logs_on_consent_form_id"
    t.index ["user_id"], name: "index_consent_logs_on_user_id"
  end

  create_table "courses", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "timezone"
    t.integer "school_id"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "number"
    t.string "anon_name"
    t.string "anon_number"
    t.integer "consent_form_id"
    t.integer "anon_offset", default: 0, null: false
    t.index ["consent_form_id"], name: "fk_rails_469f90a775"
    t.index ["school_id"], name: "index_courses_on_school_id"
  end

  create_table "criteria", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "rubric_id", null: false
    t.string "description"
    t.integer "weight", default: 1, null: false
    t.integer "sequence", null: false
    t.text "l1_description"
    t.text "l2_description"
    t.text "l3_description"
    t.text "l4_description"
    t.text "l5_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rubric_id", "sequence"], name: "index_criteria_on_rubric_id_and_sequence", unique: true
    t.index ["rubric_id"], name: "index_criteria_on_rubric_id"
  end

  create_table "delayed_jobs", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "diagnoses", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "behavior_id"
    t.integer "reaction_id"
    t.integer "week_id"
    t.text "comment"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "other_name"
    t.index ["behavior_id"], name: "index_diagnoses_on_behavior_id"
    t.index ["reaction_id"], name: "index_diagnoses_on_reaction_id"
    t.index ["week_id"], name: "index_diagnoses_on_week_id"
  end

  create_table "emails", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.boolean "primary", default: false
    t.string "confirmation_token"
    t.string "unconfirmed_email"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_emails_on_email", unique: true
    t.index ["user_id"], name: "index_emails_on_user_id"
  end

  create_table "experiences", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "course_id"
    t.string "name"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: false
    t.boolean "instructor_updated", default: false, null: false
    t.string "anon_name"
    t.integer "lead_time", default: 3, null: false
    t.datetime "student_end_date", precision: nil
    t.index ["course_id"], name: "index_experiences_on_course_id"
  end

  create_table "factor_packs", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name_en"
    t.text "description_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name_ko"
    t.text "description_ko"
    t.index ["name_en"], name: "index_factor_packs_on_name_en", unique: true
  end

  create_table "factors", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.text "description_en"
    t.string "name_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name_ko"
    t.text "description_ko"
    t.integer "factor_pack_id"
    t.index ["factor_pack_id"], name: "index_factors_on_factor_pack_id"
    t.index ["name_en"], name: "index_factors_on_name_en", unique: true
  end

  create_table "genders", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name_ko"
    t.string "code"
    t.index ["name_en"], name: "index_genders_on_name_en", unique: true
  end

  create_table "group_revisions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "group_id"
    t.string "name"
    t.string "members"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["group_id"], name: "index_group_revisions_on_group_id"
  end

  create_table "groups", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "project_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "anon_name"
    t.integer "diversity_score"
    t.index ["project_id"], name: "index_groups_on_project_id"
  end

  create_table "groups_users", id: false, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "group_id", null: false
    t.index ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", unique: true
  end

  create_table "home_countries", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.boolean "no_response"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["code"], name: "index_home_countries_on_code", unique: true
  end

  create_table "home_states", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "home_country_id"
    t.string "name"
    t.string "code"
    t.boolean "no_response"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["home_country_id", "name"], name: "index_home_states_on_home_country_id_and_name", unique: true
    t.index ["home_country_id"], name: "index_home_states_on_home_country_id"
  end

  create_table "installments", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.datetime "inst_date", precision: nil
    t.integer "assessment_id"
    t.integer "user_id"
    t.text "comments"
    t.integer "group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "anon_comments"
    t.index ["assessment_id"], name: "index_installments_on_assessment_id"
    t.index ["group_id"], name: "index_installments_on_group_id"
    t.index ["user_id"], name: "index_installments_on_user_id"
  end

  create_table "keypairs", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "jwk_kid", null: false
    t.text "_keypair_ciphertext", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "not_before", null: false
    t.datetime "not_after", null: false
    t.datetime "expires_at", null: false
    t.index ["created_at"], name: "index_keypairs_on_created_at"
    t.index ["jwk_kid"], name: "index_keypairs_on_jwk_kid", unique: true
  end

  create_table "languages", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "code"
    t.string "name_en"
    t.string "name_ko"
    t.boolean "translated"
    t.index ["code"], name: "index_languages_on_code", unique: true
    t.index ["name_en"], name: "index_languages_on_name_en", unique: true
  end

  create_table "narratives", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "member_en"
    t.integer "scenario_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "member_ko"
    t.index ["scenario_id"], name: "index_narratives_on_scenario_id"
  end

  create_table "projects", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "course_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "start_dow"
    t.integer "end_dow"
    t.boolean "active", default: false
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.integer "factor_pack_id"
    t.integer "style_id"
    t.string "anon_name"
    t.index ["course_id"], name: "index_projects_on_course_id"
    t.index ["factor_pack_id"], name: "index_projects_on_factor_pack_id"
    t.index ["style_id"], name: "index_projects_on_style_id"
  end

  create_table "quotes", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "text_en"
    t.string "attribution"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "reactions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "behavior_id"
    t.integer "narrative_id"
    t.integer "user_id"
    t.text "improvements"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "experience_id"
    t.boolean "instructed"
    t.string "other_name"
    t.integer "diagnoses_count"
    t.index ["behavior_id"], name: "index_reactions_on_behavior_id"
    t.index ["experience_id"], name: "index_reactions_on_experience_id"
    t.index ["narrative_id"], name: "index_reactions_on_narrative_id"
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "rosters", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "role", default: 4, null: false
    t.integer "course_id"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["course_id"], name: "index_rosters_on_course_id"
    t.index ["role"], name: "index_rosters_on_role"
    t.index ["user_id", "course_id"], name: "index_rosters_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_rosters_on_user_id"
  end

  create_table "rubric_row_feedbacks", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "submission_feedback_id", null: false
    t.float "score", default: 0.0, null: false
    t.text "feedback"
    t.bigint "criterium_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["criterium_id"], name: "index_rubric_row_feedbacks_on_criterium_id"
    t.index ["submission_feedback_id"], name: "index_rubric_row_feedbacks_on_submission_feedback_id"
  end

  create_table "rubrics", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "version", default: 1, null: false
    t.boolean "published", default: false, null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "school_id"
    t.string "anon_name"
    t.string "anon_description"
    t.integer "anon_version"
    t.boolean "active", default: false, null: false
    t.index ["name", "version", "parent_id"], name: "index_rubrics_on_name_and_version_and_parent_id", unique: true
    t.index ["parent_id"], name: "index_rubrics_on_parent_id"
    t.index ["school_id"], name: "index_rubrics_on_school_id"
    t.index ["user_id"], name: "index_rubrics_on_user_id"
  end

  create_table "scenarios", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name_en"
    t.integer "behavior_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name_ko"
    t.index ["behavior_id"], name: "index_scenarios_on_behavior_id"
  end

  create_table "schools", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "anon_name"
    t.string "timezone", default: "UTC", null: false
    t.integer "courses_count", default: 0, null: false
  end

  create_table "sessions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "styles", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name_en"
    t.string "filename"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name_ko"
    t.index ["name_en"], name: "index_styles_on_name_en", unique: true
  end

  create_table "submission_feedbacks", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_submission_feedbacks_on_submission_id"
  end

  create_table "submissions", charset: "utf8mb3", collation: "utf8mb3_general_ci", force: :cascade do |t|
    t.datetime "submitted"
    t.datetime "withdrawn"
    t.float "recorded_score"
    t.text "sub_text"
    t.string "sub_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "group_id"
    t.bigint "assignment_id", null: false
    t.bigint "rubric_id", null: false
    t.integer "creator_id", null: false
    t.index ["assignment_id"], name: "index_submissions_on_assignment_id"
    t.index ["creator_id"], name: "index_submissions_on_creator_id"
    t.index ["group_id"], name: "index_submissions_on_group_id"
    t.index ["rubric_id"], name: "index_submissions_on_rubric_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "gender_id"
    t.string "country"
    t.string "timezone", default: "UTC"
    t.boolean "admin"
    t.boolean "welcomed"
    t.datetime "last_emailed", precision: nil
    t.integer "school_id"
    t.string "anon_first_name"
    t.string "anon_last_name"
    t.boolean "researcher"
    t.integer "language_id", default: 40, null: false
    t.date "date_of_birth"
    t.integer "home_state_id"
    t.integer "cip_code_id"
    t.integer "primary_language_id"
    t.date "started_school"
    t.boolean "impairment_visual"
    t.boolean "impairment_auditory"
    t.boolean "impairment_motor"
    t.boolean "impairment_cognitive"
    t.boolean "impairment_other"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.text "tokens"
    t.boolean "instructor", default: false, null: false
    t.boolean "active", default: true, null: false
    t.string "theme", default: "007bff", null: false
    t.index ["cip_code_id"], name: "index_users_on_cip_code_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["gender_id"], name: "index_users_on_gender_id"
    t.index ["home_state_id"], name: "index_users_on_home_state_id"
    t.index ["language_id"], name: "index_users_on_language_id"
    t.index ["primary_language_id"], name: "index_users_on_primary_language_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "values", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "value"
    t.integer "user_id"
    t.integer "installment_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "factor_id"
    t.index ["factor_id"], name: "index_values_on_factor_id"
    t.index ["installment_id"], name: "index_values_on_installment_id"
    t.index ["user_id"], name: "index_values_on_user_id"
  end

  create_table "weeks", id: :integer, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "narrative_id"
    t.integer "week_num"
    t.text "text_en"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "text_ko"
    t.index ["narrative_id"], name: "index_weeks_on_narrative_id"
    t.index ["week_num", "narrative_id"], name: "index_weeks_on_week_num_and_narrative_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assessments", "projects"
  add_foreign_key "assignments", "courses"
  add_foreign_key "assignments", "projects"
  add_foreign_key "assignments", "rubrics"
  add_foreign_key "bingo_boards", "bingo_games"
  add_foreign_key "bingo_boards", "users"
  add_foreign_key "bingo_cells", "bingo_boards"
  add_foreign_key "bingo_cells", "candidates"
  add_foreign_key "bingo_cells", "concepts"
  add_foreign_key "bingo_games", "courses"
  add_foreign_key "bingo_games", "projects"
  add_foreign_key "candidate_lists", "bingo_games"
  add_foreign_key "candidate_lists", "candidate_lists", column: "current_candidate_list_id"
  add_foreign_key "candidate_lists", "groups"
  add_foreign_key "candidate_lists", "users"
  add_foreign_key "candidates", "candidate_feedbacks"
  add_foreign_key "candidates", "candidate_lists"
  add_foreign_key "candidates", "concepts"
  add_foreign_key "candidates", "users"
  add_foreign_key "consent_forms", "users"
  add_foreign_key "consent_logs", "consent_forms"
  add_foreign_key "consent_logs", "users"
  add_foreign_key "courses", "consent_forms"
  add_foreign_key "courses", "schools"
  add_foreign_key "criteria", "rubrics"
  add_foreign_key "diagnoses", "behaviors"
  add_foreign_key "diagnoses", "reactions"
  add_foreign_key "diagnoses", "weeks"
  add_foreign_key "emails", "users"
  add_foreign_key "experiences", "courses"
  add_foreign_key "factors", "factor_packs"
  add_foreign_key "group_revisions", "groups"
  add_foreign_key "groups", "projects"
  add_foreign_key "home_states", "home_countries"
  add_foreign_key "installments", "assessments"
  add_foreign_key "installments", "groups"
  add_foreign_key "installments", "users"
  add_foreign_key "narratives", "scenarios"
  add_foreign_key "projects", "courses"
  add_foreign_key "projects", "factor_packs"
  add_foreign_key "projects", "styles"
  add_foreign_key "reactions", "behaviors"
  add_foreign_key "reactions", "experiences"
  add_foreign_key "reactions", "narratives"
  add_foreign_key "reactions", "users"
  add_foreign_key "rosters", "courses"
  add_foreign_key "rosters", "users"
  add_foreign_key "rubric_row_feedbacks", "criteria"
  add_foreign_key "rubric_row_feedbacks", "submission_feedbacks"
  add_foreign_key "rubrics", "rubrics", column: "parent_id"
  add_foreign_key "rubrics", "schools"
  add_foreign_key "rubrics", "users"
  add_foreign_key "scenarios", "behaviors"
  add_foreign_key "submission_feedbacks", "submissions"
  add_foreign_key "submissions", "assignments"
  add_foreign_key "submissions", "groups"
  add_foreign_key "submissions", "rubrics"
  add_foreign_key "submissions", "users"
  add_foreign_key "submissions", "users", column: "creator_id"
  add_foreign_key "users", "cip_codes"
  add_foreign_key "users", "genders"
  add_foreign_key "users", "home_states"
  add_foreign_key "users", "languages"
  add_foreign_key "users", "schools"
  add_foreign_key "values", "factors"
  add_foreign_key "values", "installments"
  add_foreign_key "values", "users"
  add_foreign_key "weeks", "narratives"
end
