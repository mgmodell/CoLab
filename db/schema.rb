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

ActiveRecord::Schema.define(version: 20170524112411) do

  create_table "age_ranges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "assessments", force: :cascade do |t|
    t.datetime "end_date"
    t.datetime "start_date"
    t.integer  "project_id",         limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "instructor_updated",           default: false, null: false
  end

  add_index "assessments", ["project_id"], name: "index_assessments_on_project_id", using: :btree

  create_table "behaviors", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "bingo_games", force: :cascade do |t|
    t.string   "topic",               limit: 255
    t.text     "description",         limit: 65535
    t.string   "link",                limit: 255
    t.string   "source",              limit: 255
    t.boolean  "group_option"
    t.integer  "individual_count",    limit: 4
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "active"
    t.integer  "course_id",           limit: 4
    t.integer  "project_id",          limit: 4
    t.integer  "lead_time",           limit: 4
    t.integer  "group_discount",      limit: 4
    t.boolean  "reviewed"
    t.boolean  "instructor_notified",               default: false, null: false
    t.boolean  "students_notified",                 default: false, null: false
    t.string   "anon_topic",          limit: 255
  end

  add_index "bingo_games", ["course_id"], name: "index_bingo_games_on_course_id", using: :btree
  add_index "bingo_games", ["project_id"], name: "index_bingo_games_on_project_id", using: :btree

  create_table "candidate_feedbacks", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "definition", limit: 255
  end

  create_table "candidate_lists", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "group_id",        limit: 4
    t.boolean  "is_group"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "bingo_game_id",   limit: 4
    t.boolean  "group_requested"
  end

  add_index "candidate_lists", ["bingo_game_id"], name: "index_candidate_lists_on_bingo_game_id", using: :btree
  add_index "candidate_lists", ["group_id"], name: "index_candidate_lists_on_group_id", using: :btree
  add_index "candidate_lists", ["user_id"], name: "index_candidate_lists_on_user_id", using: :btree

  create_table "candidates", force: :cascade do |t|
    t.text     "definition",            limit: 65535
    t.integer  "candidate_list_id",     limit: 4
    t.integer  "candidate_feedback_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "concept_id",            limit: 4
    t.string   "term",                  limit: 255
    t.integer  "user_id",               limit: 4,     null: false
  end

  add_index "candidates", ["candidate_feedback_id"], name: "index_candidates_on_candidate_feedback_id", using: :btree
  add_index "candidates", ["candidate_list_id"], name: "index_candidates_on_candidate_list_id", using: :btree
  add_index "candidates", ["concept_id"], name: "index_candidates_on_concept_id", using: :btree
  add_index "candidates", ["user_id"], name: "index_candidates_on_user_id", using: :btree

  create_table "cip_codes", force: :cascade do |t|
    t.integer  "gov_code",    limit: 4
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "concepts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "consent_forms", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "user_id",          limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "pdf_file_name",    limit: 255
    t.string   "pdf_content_type", limit: 255
    t.integer  "pdf_file_size",    limit: 4
    t.datetime "pdf_updated_at"
    t.text     "form_text",        limit: 65535
  end

  add_index "consent_forms", ["user_id"], name: "index_consent_forms_on_user_id", using: :btree

  create_table "consent_logs", force: :cascade do |t|
    t.boolean  "accepted"
    t.integer  "consent_form_id", limit: 4
    t.integer  "user_id",         limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "presented"
  end

  add_index "consent_logs", ["consent_form_id"], name: "index_consent_logs_on_consent_form_id", using: :btree
  add_index "consent_logs", ["user_id"], name: "index_consent_logs_on_user_id", using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "timezone",    limit: 255
    t.integer  "school_id",   limit: 4
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "number",      limit: 255
    t.string   "anon_name",   limit: 255
    t.string   "anon_number", limit: 255
  end

  add_index "courses", ["school_id"], name: "index_courses_on_school_id", using: :btree

  create_table "diagnoses", force: :cascade do |t|
    t.integer  "behavior_id", limit: 4
    t.integer  "reaction_id", limit: 4
    t.integer  "week_id",     limit: 4
    t.text     "comment",     limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "other_name",  limit: 255
  end

  add_index "diagnoses", ["behavior_id"], name: "index_diagnoses_on_behavior_id", using: :btree
  add_index "diagnoses", ["reaction_id"], name: "index_diagnoses_on_reaction_id", using: :btree
  add_index "diagnoses", ["week_id"], name: "index_diagnoses_on_week_id", using: :btree

  create_table "emails", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.string   "email",                limit: 255
    t.boolean  "primary",                          default: false
    t.string   "confirmation_token",   limit: 255
    t.string   "unconfirmed_email",    limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "emails", ["user_id"], name: "index_emails_on_user_id", using: :btree

  create_table "experiences", force: :cascade do |t|
    t.integer  "course_id",          limit: 4
    t.string   "name",               limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "active"
    t.boolean  "instructor_updated",             default: false, null: false
    t.string   "anon_name",          limit: 255
  end

  add_index "experiences", ["course_id"], name: "index_experiences_on_course_id", using: :btree

  create_table "factor_packs", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "factor_packs_factors", id: false, force: :cascade do |t|
    t.integer "factor_id",      limit: 4, null: false
    t.integer "factor_pack_id", limit: 4, null: false
  end

  create_table "factors", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "genders", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "group_project_counts", force: :cascade do |t|
    t.string "name",        limit: 255
    t.string "description", limit: 255
  end

  create_table "group_revisions", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.string   "name",       limit: 255
    t.string   "members",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "group_revisions", ["group_id"], name: "index_group_revisions_on_group_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "project_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "anon_name",  limit: 255
  end

  add_index "groups", ["project_id"], name: "index_groups_on_project_id", using: :btree

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "user_id",  limit: 4, null: false
    t.integer "group_id", limit: 4, null: false
  end

  add_index "groups_users", ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", unique: true, using: :btree

  create_table "installments", force: :cascade do |t|
    t.datetime "inst_date"
    t.integer  "assessment_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.text     "comments",      limit: 65535
    t.integer  "group_id",      limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "installments", ["assessment_id"], name: "index_installments_on_assessment_id", using: :btree
  add_index "installments", ["group_id"], name: "index_installments_on_group_id", using: :btree
  add_index "installments", ["user_id"], name: "index_installments_on_user_id", using: :btree

  create_table "narratives", force: :cascade do |t|
    t.string   "member",      limit: 255
    t.integer  "scenario_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "narratives", ["scenario_id"], name: "index_narratives_on_scenario_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "description",     limit: 255
    t.integer  "course_id",       limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "start_dow",       limit: 4
    t.integer  "end_dow",         limit: 4
    t.boolean  "active"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "consent_form_id", limit: 4
    t.integer  "factor_pack_id",  limit: 4
    t.integer  "style_id",        limit: 4
    t.string   "anon_name",       limit: 255
  end

  add_index "projects", ["consent_form_id"], name: "index_projects_on_consent_form_id", using: :btree
  add_index "projects", ["course_id"], name: "index_projects_on_course_id", using: :btree
  add_index "projects", ["factor_pack_id"], name: "index_projects_on_factor_pack_id", using: :btree
  add_index "projects", ["style_id"], name: "index_projects_on_style_id", using: :btree

  create_table "reactions", force: :cascade do |t|
    t.integer  "behavior_id",   limit: 4
    t.integer  "narrative_id",  limit: 4
    t.integer  "user_id",       limit: 4
    t.text     "improvements",  limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "experience_id", limit: 4
    t.boolean  "instructed"
    t.string   "other_name",    limit: 255
  end

  add_index "reactions", ["behavior_id"], name: "index_reactions_on_behavior_id", using: :btree
  add_index "reactions", ["experience_id"], name: "index_reactions_on_experience_id", using: :btree
  add_index "reactions", ["narrative_id"], name: "index_reactions_on_narrative_id", using: :btree
  add_index "reactions", ["user_id"], name: "index_reactions_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "rosters", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "course_id",  limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "rosters", ["course_id"], name: "index_rosters_on_course_id", using: :btree
  add_index "rosters", ["role_id"], name: "index_rosters_on_role_id", using: :btree
  add_index "rosters", ["user_id"], name: "index_rosters_on_user_id", using: :btree

  create_table "scenarios", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "behavior_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "scenarios", ["behavior_id"], name: "index_scenarios_on_behavior_id", using: :btree

  create_table "schools", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "anon_name",   limit: 255
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "styles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "filename",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "themes", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0,  null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.integer  "gender_id",              limit: 4
    t.integer  "age_range_id",           limit: 4
    t.string   "country",                limit: 255
    t.string   "timezone",               limit: 255
    t.boolean  "admin"
    t.boolean  "welcomed"
    t.datetime "last_emailed"
    t.integer  "theme_id",               limit: 4,   default: 1
    t.integer  "school_id",              limit: 4
    t.string   "anon_first_name",        limit: 255
    t.string   "anon_last_name",         limit: 255
    t.boolean  "researcher"
  end

  add_index "users", ["age_range_id"], name: "index_users_on_age_range_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["gender_id"], name: "index_users_on_gender_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["school_id"], name: "index_users_on_school_id", using: :btree
  add_index "users", ["theme_id"], name: "index_users_on_theme_id", using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "values", force: :cascade do |t|
    t.integer  "value",          limit: 4
    t.integer  "user_id",        limit: 4
    t.integer  "installment_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "factor_id",      limit: 4
  end

  add_index "values", ["factor_id"], name: "index_values_on_factor_id", using: :btree
  add_index "values", ["installment_id"], name: "index_values_on_installment_id", using: :btree
  add_index "values", ["user_id"], name: "index_values_on_user_id", using: :btree

  create_table "weeks", force: :cascade do |t|
    t.integer  "narrative_id", limit: 4
    t.integer  "week_num",     limit: 4
    t.text     "text",         limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "weeks", ["narrative_id"], name: "index_weeks_on_narrative_id", using: :btree

  add_foreign_key "assessments", "projects"
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
  add_foreign_key "group_revisions", "groups"
  add_foreign_key "groups", "projects"
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
  add_foreign_key "rosters", "roles"
  add_foreign_key "rosters", "users"
  add_foreign_key "scenarios", "behaviors"
  add_foreign_key "users", "age_ranges"
  add_foreign_key "users", "genders"
  add_foreign_key "users", "schools"
  add_foreign_key "users", "themes"
  add_foreign_key "values", "factors"
  add_foreign_key "values", "installments"
  add_foreign_key "values", "users"
  add_foreign_key "weeks", "narratives"
end
