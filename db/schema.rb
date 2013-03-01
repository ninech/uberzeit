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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130301141103) do

  create_table "employments", :force => true do |t|
    t.integer  "user_id"
    t.date     "start_date"
    t.date     "end_date"
    t.float    "workload",   :default => 100.0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.time     "deleted_at"
  end

  add_index "employments", ["user_id"], :name => "index_employments_on_user_id"

  create_table "memberships", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "memberships", ["team_id", "user_id", "role"], :name => "index_memberships_on_team_id_and_user_id_and_role", :unique => true
  add_index "memberships", ["team_id"], :name => "index_memberships_on_team_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "recurring_entries", :force => true do |t|
    t.integer  "time_sheet_id"
    t.integer  "time_type_id"
    t.text     "schedule_hash"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.time     "deleted_at"
  end

  add_index "recurring_entries", ["time_sheet_id"], :name => "index_recurring_entries_on_time_sheet_id"
  add_index "recurring_entries", ["time_type_id"], :name => "index_recurring_entries_on_time_type_id"

  create_table "single_entries", :force => true do |t|
    t.integer  "time_sheet_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "time_type_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.time     "deleted_at"
    t.boolean  "whole_day",     :default => false
  end

  add_index "single_entries", ["time_sheet_id"], :name => "index_single_entries_on_time_sheet_id"
  add_index "single_entries", ["time_type_id"], :name => "index_single_entries_on_time_type_id"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "ldap_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
  end

  create_table "time_sheets", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
  end

  add_index "time_sheets", ["user_id"], :name => "index_time_sheets_on_user_id"

  create_table "time_types", :force => true do |t|
    t.string   "name"
    t.boolean  "is_work",     :default => false
    t.boolean  "is_vacation", :default => false
    t.boolean  "is_onduty",   :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.time     "deleted_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "ldap_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
    t.string   "time_zone"
  end

end
