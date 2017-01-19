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

ActiveRecord::Schema.define(version: 20170118070916) do

  create_table "age_ranges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "assessments", force: :cascade do |t|
    t.date     "end_date"
    t.string   "start_date", limit: 255
    t.integer  "project_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "assessments", ["project_id"], name: "index_assessments_on_project_id", using: :btree

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
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "number",      limit: 255
  end

  add_index "courses", ["school_id"], name: "index_courses_on_school_id", using: :btree

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

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "project_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "groups", ["project_id"], name: "index_groups_on_project_id", using: :btree

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "user_id",  limit: 4, null: false
    t.integer "group_id", limit: 4, null: false
  end

  add_index "groups_users", ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", unique: true, using: :btree

  create_table "installments", force: :cascade do |t|
    t.date     "inst_date"
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

  create_table "projects", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "description",     limit: 255
    t.integer  "course_id",       limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "start_dow",       limit: 4
    t.integer  "end_dow",         limit: 4
    t.boolean  "active"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "consent_form_id", limit: 4
    t.integer  "factor_pack_id",  limit: 4
  end

  add_index "projects", ["consent_form_id"], name: "index_projects_on_consent_form_id", using: :btree
  add_index "projects", ["course_id"], name: "index_projects_on_course_id", using: :btree
  add_index "projects", ["factor_pack_id"], name: "index_projects_on_factor_pack_id", using: :btree

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

  create_table "schools", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "styles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "filename",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
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
    t.boolean  "admin"
    t.boolean  "welcomed"
  end

  add_index "users", ["age_range_id"], name: "index_users_on_age_range_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["gender_id"], name: "index_users_on_gender_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "values", force: :cascade do |t|
    t.integer  "value",          limit: 4
    t.integer  "user_id",        limit: 4
    t.integer  "installment_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "values", ["installment_id"], name: "index_values_on_installment_id", using: :btree
  add_index "values", ["user_id"], name: "index_values_on_user_id", using: :btree

  add_foreign_key "assessments", "projects"
  add_foreign_key "consent_forms", "users"
  add_foreign_key "consent_logs", "consent_forms"
  add_foreign_key "consent_logs", "users"
  add_foreign_key "courses", "schools"
  add_foreign_key "groups", "projects"
  add_foreign_key "installments", "assessments"
  add_foreign_key "installments", "groups"
  add_foreign_key "installments", "users"
  add_foreign_key "projects", "consent_forms"
  add_foreign_key "projects", "courses"
  add_foreign_key "projects", "factor_packs"
  add_foreign_key "rosters", "courses"
  add_foreign_key "rosters", "roles"
  add_foreign_key "rosters", "users"
  add_foreign_key "users", "age_ranges"
  add_foreign_key "users", "genders"
  add_foreign_key "values", "installments"
  add_foreign_key "values", "users"
end
