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

ActiveRecord::Schema.define(:version => 20130503101350) do

  create_table "absences", :force => true do |t|
    t.integer  "time_sheet_id"
    t.integer  "time_type_id"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "first_half_day",  :default => false
    t.boolean  "second_half_day", :default => false
    t.datetime "deleted_at"
  end

  add_index "absences", ["time_sheet_id"], :name => "index_date_entries_on_time_sheet_id"
  add_index "absences", ["time_type_id"], :name => "index_date_entries_on_time_type_id"

  create_table "employments", :force => true do |t|
    t.integer  "user_id"
    t.date     "start_date"
    t.date     "end_date"
    t.float    "workload",   :default => 100.0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.datetime "deleted_at"
  end

  add_index "employments", ["user_id"], :name => "index_employments_on_user_id"

  create_table "exception_dates", :force => true do |t|
    t.integer  "recurring_schedule_id"
    t.date     "date"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "exception_dates", ["recurring_schedule_id"], :name => "index_exception_dates_on_recurring_schedule_id"

  create_table "memberships", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "memberships", ["team_id"], :name => "index_memberships_on_team_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "public_holidays", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "name"
    t.boolean  "first_half_day",  :default => false
    t.boolean  "second_half_day", :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "deleted_at"
  end

  create_table "recurring_schedules", :force => true do |t|
    t.boolean  "active",                 :default => false
    t.integer  "enterable_id"
    t.string   "enterable_type"
    t.string   "ends"
    t.integer  "ends_counter"
    t.date     "ends_date"
    t.integer  "weekly_repeat_interval"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
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
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "deleted_at"
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
    t.datetime "deleted_at"
  end

  add_index "time_sheets", ["user_id"], :name => "index_time_sheets_on_user_id"

  create_table "time_types", :force => true do |t|
    t.string   "name"
    t.boolean  "is_work",                  :default => false
    t.boolean  "is_vacation",              :default => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.datetime "deleted_at"
    t.string   "icon"
    t.integer  "color_index",              :default => 0
    t.float    "bonus_factor",             :default => 0.0
    t.boolean  "exclude_from_calculation", :default => false
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
    t.datetime "deleted_at"
    t.string   "time_zone"
    t.string   "given_name"
    t.date     "birthday"
  end

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
