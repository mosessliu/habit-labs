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

ActiveRecord::Schema.define(version: 2018_06_01_054612) do

  create_table "habit_invitations", force: :cascade do |t|
    t.integer "habit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_id"], name: "index_habit_invitations_on_habit_id"
  end

  create_table "habits", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "duration"
    t.integer "frequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "end_datetime"
    t.boolean "finished", default: false
  end

  create_table "user_habit_deadlines", force: :cascade do |t|
    t.integer "user_habit_id"
    t.datetime "deadline"
    t.boolean "completed", default: false
    t.index ["user_habit_id"], name: "index_user_habit_deadlines_on_user_habit_id"
  end

  create_table "user_habit_invitations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "habit_invitation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_invitation_id"], name: "index_user_habit_invitations_on_habit_invitation_id"
    t.index ["user_id"], name: "index_user_habit_invitations_on_user_id"
  end

  create_table "user_habits", force: :cascade do |t|
    t.integer "user_id"
    t.integer "habit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_id"], name: "index_user_habits_on_habit_id"
    t.index ["user_id"], name: "index_user_habits_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
