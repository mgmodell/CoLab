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

ActiveRecord::Schema.define(version: 20180115065402) do

  create_table "assessments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "end_date"
    t.datetime "start_date"
    t.integer  "project_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "instructor_updated", default: false, null: false
    t.index ["project_id"], name: "index_assessments_on_project_id", using: :btree
  end

  create_table "behaviors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name_en"
    t.text     "description_en", limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "name_ko"
    t.string   "description_ko"
    t.index ["name_en"], name: "index_behaviors_on_name_en", unique: true, using: :btree
  end

  create_table "bingo_boards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "bingo_game_id"
    t.integer  "user_id"
    t.integer  "winner"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "win_claimed"
    t.index ["bingo_game_id"], name: "index_bingo_boards_on_bingo_game_id", using: :btree
    t.index ["user_id"], name: "index_bingo_boards_on_user_id", using: :btree
  end

  create_table "bingo_cells", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "bingo_board_id"
    t.integer  "concept_id"
    t.integer  "row"
    t.integer  "column"
    t.boolean  "selected"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["bingo_board_id"], name: "index_bingo_cells_on_bingo_board_id", using: :btree
    t.index ["concept_id"], name: "index_bingo_cells_on_concept_id", using: :btree
  end

  create_table "bingo_games", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "topic"
    t.text     "description",         limit: 65535
    t.string   "link"
    t.string   "source"
    t.boolean  "group_option"
    t.integer  "individual_count"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "active"
    t.integer  "course_id"
    t.integer  "project_id"
    t.integer  "lead_time"
    t.integer  "group_discount"
    t.boolean  "reviewed"
    t.boolean  "instructor_notified",               default: false, null: false
    t.boolean  "students_notified",                 default: false, null: false
    t.string   "anon_topic"
    t.index ["course_id"], name: "index_bingo_games_on_course_id", using: :btree
    t.index ["project_id"], name: "index_bingo_games_on_project_id", using: :btree
  end

  create_table "candidate_feedbacks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name_en"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "name_ko"
    t.text     "definition_en", limit: 65535
    t.text     "definition_ko", limit: 65535
    t.integer  "credit"
    t.index ["name_en"], name: "index_candidate_feedbacks_on_name_en", unique: true, using: :btree
  end

  create_table "candidate_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "is_group"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "bingo_game_id"
    t.boolean  "group_requested"
    t.integer  "cached_performance"
    t.index ["bingo_game_id"], name: "index_candidate_lists_on_bingo_game_id", using: :btree
    t.index ["group_id"], name: "index_candidate_lists_on_group_id", using: :btree
    t.index ["user_id"], name: "index_candidate_lists_on_user_id", using: :btree
  end

  create_table "candidates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "definition",            limit: 65535
    t.integer  "candidate_list_id"
    t.integer  "candidate_feedback_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "concept_id"
    t.string   "term"
    t.integer  "user_id",                             null: false
    t.string   "filtered_consistent"
    t.index ["candidate_feedback_id"], name: "index_candidates_on_candidate_feedback_id", using: :btree
    t.index ["candidate_list_id"], name: "index_candidates_on_candidate_list_id", using: :btree
    t.index ["concept_id"], name: "index_candidates_on_concept_id", using: :btree
    t.index ["definition"], name: "index_candidates_on_definition", length: { definition: 2 }, using: :btree
    t.index ["term"], name: "index_candidates_on_term", length: { term: 2 }, using: :btree
    t.index ["user_id"], name: "index_candidates_on_user_id", using: :btree
  end

  create_table "cip_codes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "gov_code"
    t.string   "name_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name_ko"
    t.index ["gov_code"], name: "index_cip_codes_on_gov_code", unique: true, using: :btree
  end

  create_table "concepts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "concept_fulltext", type: :fulltext
    t.index ["name"], name: "index_concepts_on_name", unique: true, using: :btree
  end

  create_table "consent_forms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "pdf_file_name"
    t.string   "pdf_content_type"
    t.integer  "pdf_file_size"
    t.datetime "pdf_updated_at"
    t.text     "form_text_en",     limit: 65535
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "active",                         default: false, null: false
    t.text     "form_text_ko",     limit: 65535
    t.index ["user_id"], name: "index_consent_forms_on_user_id", using: :btree
  end

  create_table "consent_logs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.boolean  "accepted"
    t.integer  "consent_form_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "presented"
    t.index ["consent_form_id"], name: "index_consent_logs_on_consent_form_id", using: :btree
    t.index ["user_id"], name: "index_consent_logs_on_user_id", using: :btree
  end

  create_table "courses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.string   "timezone"
    t.integer  "school_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "number"
    t.string   "anon_name"
    t.string   "anon_number"
    t.index ["school_id"], name: "index_courses_on_school_id", using: :btree
  end

  create_table "diagnoses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "behavior_id"
    t.integer  "reaction_id"
    t.integer  "week_id"
    t.text     "comment",     limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "other_name"
    t.index ["behavior_id"], name: "index_diagnoses_on_behavior_id", using: :btree
    t.index ["reaction_id"], name: "index_diagnoses_on_reaction_id", using: :btree
    t.index ["week_id"], name: "index_diagnoses_on_week_id", using: :btree
  end

  create_table "emails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "email"
    t.boolean  "primary",              default: false
    t.string   "confirmation_token"
    t.string   "unconfirmed_email"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["email"], name: "index_emails_on_email", unique: true, using: :btree
    t.index ["user_id"], name: "index_emails_on_user_id", using: :btree
  end

  create_table "experiences", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "course_id"
    t.string   "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "active"
    t.boolean  "instructor_updated", default: false, null: false
    t.string   "anon_name"
    t.index ["course_id"], name: "index_experiences_on_course_id", using: :btree
  end

  create_table "factor_packs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name_en"
    t.text     "description_en", limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "name_ko"
    t.string   "description_ko"
    t.index ["name_en"], name: "index_factor_packs_on_name_en", unique: true, using: :btree
  end

  create_table "factors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "description_en"
    t.string   "name_en"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "name_ko"
    t.string   "description_ko"
    t.integer  "factor_pack_id"
    t.index ["factor_pack_id"], name: "index_factors_on_factor_pack_id", using: :btree
    t.index ["name_en"], name: "index_factors_on_name_en", unique: true, using: :btree
  end

  create_table "genders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name_ko"
    t.string   "code"
    t.index ["name_en"], name: "index_genders_on_name_en", unique: true, using: :btree
  end

  create_table "group_revisions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "group_id"
    t.string   "name"
    t.string   "members"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_revisions_on_group_id", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "anon_name"
    t.integer  "diversity_score"
    t.index ["project_id"], name: "index_groups_on_project_id", using: :btree
  end

  create_table "groups_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id",  null: false
    t.integer "group_id", null: false
    t.index ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", unique: true, using: :btree
  end

  create_table "home_countries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "code"
    t.boolean  "no_response"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["code"], name: "index_home_countries_on_code", unique: true, using: :btree
  end

  create_table "home_states", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "home_country_id"
    t.string   "name"
    t.string   "code"
    t.boolean  "no_response"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["home_country_id", "name"], name: "index_home_states_on_home_country_id_and_name", unique: true, using: :btree
    t.index ["home_country_id"], name: "index_home_states_on_home_country_id", using: :btree
  end

  create_table "installments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "inst_date"
    t.integer  "assessment_id"
    t.integer  "user_id"
    t.text     "comments",      limit: 65535
    t.integer  "group_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "anon_comments", limit: 65535
    t.index ["assessment_id"], name: "index_installments_on_assessment_id", using: :btree
    t.index ["group_id"], name: "index_installments_on_group_id", using: :btree
    t.index ["user_id"], name: "index_installments_on_user_id", using: :btree
  end

  create_table "languages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "code"
    t.string  "name_en"
    t.string  "name_ko"
    t.boolean "translated"
    t.index ["code"], name: "index_languages_on_code", unique: true, using: :btree
    t.index ["name_en"], name: "index_languages_on_name_en", unique: true, using: :btree
  end

  create_table "narratives", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "member_en"
    t.integer  "scenario_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "member_ko"
    t.index ["scenario_id"], name: "index_narratives_on_scenario_id", using: :btree
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "course_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "start_dow"
    t.integer  "end_dow"
    t.boolean  "active"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "consent_form_id"
    t.integer  "factor_pack_id"
    t.integer  "style_id"
    t.string   "anon_name"
    t.index ["consent_form_id"], name: "index_projects_on_consent_form_id", using: :btree
    t.index ["course_id"], name: "index_projects_on_course_id", using: :btree
    t.index ["factor_pack_id"], name: "index_projects_on_factor_pack_id", using: :btree
    t.index ["style_id"], name: "index_projects_on_style_id", using: :btree
  end

  create_table "quotes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "text_en"
    t.string   "attribution"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "reactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "behavior_id"
    t.integer  "narrative_id"
    t.integer  "user_id"
    t.text     "improvements",  limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "experience_id"
    t.boolean  "instructed"
    t.string   "other_name"
    t.index ["behavior_id"], name: "index_reactions_on_behavior_id", using: :btree
    t.index ["experience_id"], name: "index_reactions_on_experience_id", using: :btree
    t.index ["narrative_id"], name: "index_reactions_on_narrative_id", using: :btree
    t.index ["user_id"], name: "index_reactions_on_user_id", using: :btree
  end

  create_table "rosters", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "role",       default: 4, null: false
    t.integer  "course_id"
    t.integer  "user_id",                null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["course_id"], name: "index_rosters_on_course_id", using: :btree
    t.index ["role"], name: "index_rosters_on_role", using: :btree
    t.index ["user_id"], name: "index_rosters_on_user_id", using: :btree
  end

  create_table "scenarios", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name_en"
    t.integer  "behavior_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name_ko"
    t.index ["behavior_id"], name: "index_scenarios_on_behavior_id", using: :btree
  end

  create_table "schools", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "description"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "anon_name"
  end

  create_table "sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "session_id",               null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "styles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name_en"
    t.string   "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name_ko"
    t.index ["name_en"], name: "index_styles_on_name_en", unique: true, using: :btree
  end

  create_table "themes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "code"
    t.string   "name_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name_ko"
    t.index ["code"], name: "index_themes_on_code", unique: true, using: :btree
    t.index ["name_en"], name: "index_themes_on_name_en", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "gender_id"
    t.string   "country"
    t.string   "timezone"
    t.boolean  "admin"
    t.boolean  "welcomed"
    t.datetime "last_emailed"
    t.integer  "theme_id",               default: 1
    t.integer  "school_id"
    t.string   "anon_first_name"
    t.string   "anon_last_name"
    t.boolean  "researcher"
    t.integer  "language_id"
    t.date     "date_of_birth"
    t.integer  "home_state_id"
    t.integer  "cip_code_id"
    t.integer  "primary_language_id"
    t.date     "started_school"
    t.boolean  "impairment_visual"
    t.boolean  "impairment_auditory"
    t.boolean  "impairment_motor"
    t.boolean  "impairment_cognitive"
    t.boolean  "impairment_other"
    t.index ["cip_code_id"], name: "index_users_on_cip_code_id", using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["gender_id"], name: "index_users_on_gender_id", using: :btree
    t.index ["home_state_id"], name: "index_users_on_home_state_id", using: :btree
    t.index ["language_id"], name: "index_users_on_language_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["school_id"], name: "index_users_on_school_id", using: :btree
    t.index ["theme_id"], name: "index_users_on_theme_id", using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  create_table "values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "value"
    t.integer  "user_id"
    t.integer  "installment_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "factor_id"
    t.index ["factor_id"], name: "index_values_on_factor_id", using: :btree
    t.index ["installment_id"], name: "index_values_on_installment_id", using: :btree
    t.index ["user_id"], name: "index_values_on_user_id", using: :btree
  end

  create_table "weeks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "narrative_id"
    t.integer  "week_num"
    t.text     "text_en",      limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "text_ko",      limit: 65535
    t.index ["narrative_id"], name: "index_weeks_on_narrative_id", using: :btree
    t.index ["week_num", "narrative_id"], name: "index_weeks_on_week_num_and_narrative_id", unique: true, using: :btree
  end

  add_foreign_key "assessments", "projects"
  add_foreign_key "bingo_boards", "bingo_games"
  add_foreign_key "bingo_boards", "users"
  add_foreign_key "bingo_cells", "bingo_boards"
  add_foreign_key "bingo_cells", "concepts"
  add_foreign_key "bingo_games", "courses"
  add_foreign_key "bingo_games", "projects"
  add_foreign_key "candidate_lists", "bingo_games"
  add_foreign_key "candidate_lists", "groups"
  add_foreign_key "candidate_lists", "users"
  add_foreign_key "candidates", "candidate_feedbacks"
  add_foreign_key "candidates", "candidate_lists"
  add_foreign_key "candidates", "concepts"
  add_foreign_key "candidates", "users"
  add_foreign_key "consent_forms", "users"
  add_foreign_key "consent_logs", "consent_forms"
  add_foreign_key "consent_logs", "users"
  add_foreign_key "courses", "schools"
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
  add_foreign_key "projects", "consent_forms"
  add_foreign_key "projects", "courses"
  add_foreign_key "projects", "factor_packs"
  add_foreign_key "projects", "styles"
  add_foreign_key "reactions", "behaviors"
  add_foreign_key "reactions", "experiences"
  add_foreign_key "reactions", "narratives"
  add_foreign_key "reactions", "users"
  add_foreign_key "rosters", "courses"
  add_foreign_key "rosters", "users"
  add_foreign_key "scenarios", "behaviors"
  add_foreign_key "users", "cip_codes"
  add_foreign_key "users", "genders"
  add_foreign_key "users", "home_states"
  add_foreign_key "users", "languages"
  add_foreign_key "users", "schools"
  add_foreign_key "users", "themes"
  add_foreign_key "values", "factors"
  add_foreign_key "values", "installments"
  add_foreign_key "values", "users"
  add_foreign_key "weeks", "narratives"
end
