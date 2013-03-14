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

ActiveRecord::Schema.define(:version => 20130313154110) do

  create_table "date_entries", :force => true do |t|
    t.integer  "time_sheet_id"
    t.integer  "time_type_id"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "first_half_day",  :default => false
    t.boolean  "second_half_day", :default => false
    t.datetime "deleted_at"
  end

  add_index "date_entries", ["time_sheet_id"], :name => "index_date_entries_on_time_sheet_id"
  add_index "date_entries", ["time_type_id"], :name => "index_date_entries_on_time_type_id"

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

  create_table "recurring_schedules", :force => true do |t|
    t.boolean  "active",                  :default => false
    t.integer  "enterable_id"
    t.string   "enterable_type"
    t.string   "ends"
    t.integer  "ends_counter"
    t.date     "ends_date"
    t.string   "repeat_interval_type"
    t.integer  "daily_repeat_interval"
    t.integer  "weekly_repeat_interval"
    t.string   "weekly_repeat_weekday"
    t.integer  "monthly_repeat_interval"
    t.string   "monthly_repeat_by"
    t.integer  "yearly_repeat_interval"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.datetime "deleted_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "ldap_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
  end

  create_table "time_entries", :force => true do |t|
    t.integer  "time_sheet_id"
    t.integer  "time_type_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "deleted_at"
  end

  add_index "time_entries", ["time_sheet_id"], :name => "index_time_entries_on_time_sheet_id"
  add_index "time_entries", ["time_type_id"], :name => "index_time_entries_on_time_type_id"

  create_table "time_sheets", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
  end

  add_index "time_sheets", ["user_id"], :name => "index_time_sheets_on_user_id"

  create_table "time_types", :force => true do |t|
    t.string   "name"
    t.boolean  "is_work",       :default => false
    t.boolean  "is_vacation",   :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.time     "deleted_at"
    t.boolean  "treat_as_work", :default => false
    t.boolean  "daywise"
    t.boolean  "timewise"
  end

  create_table "timers", :force => true do |t|
    t.integer  "time_sheet_id"
    t.integer  "time_type_id"
    t.datetime "start_time"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "timers", ["time_sheet_id"], :name => "index_timers_on_time_sheet_id"
  add_index "timers", ["time_type_id"], :name => "index_timers_on_time_type_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "deleted_at"
    t.string   "time_zone"
  end

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
