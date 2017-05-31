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

ActiveRecord::Schema.define(version: 20170531164512) do

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "event_items", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "description"
    t.decimal  "price",        precision: 9, scale: 2
    t.decimal  "tax",          precision: 6, scale: 5
    t.integer  "max_event"
    t.integer  "max_order"
    t.integer  "min_freq"
    t.boolean  "flat_rate",                            default: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.datetime "deleted_at"
    t.string   "check_status"
    t.index ["deleted_at"], name: "index_event_items_on_deleted_at"
    t.index ["event_id"], name: "index_event_items_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.text     "page_body"
    t.datetime "available_at"
    t.datetime "unavailable_at"
    t.datetime "starts_on"
    t.datetime "ends_on"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "deleted_at"
    t.string   "attachment"
    t.index ["deleted_at"], name: "index_events_on_deleted_at"
  end

  create_table "order_product_items", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "order_product_id"
    t.integer  "quantity"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_order_product_items_on_deleted_at"
    t.index ["order_product_id"], name: "index_order_product_items_on_order_product_id"
    t.index ["product_id"], name: "index_order_product_items_on_product_id"
  end

  create_table "order_products", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "total",           precision: 9, scale: 2
    t.string   "status"
    t.text     "payment_details"
    t.string   "auth_code"
    t.string   "transaction_id"
    t.datetime "placed_at"
    t.datetime "finalized_on"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_order_products_on_deleted_at"
    t.index ["user_id"], name: "index_order_products_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_item_id"
    t.integer  "quantity"
    t.decimal  "total",           precision: 9, scale: 2
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "status"
    t.text     "comment"
    t.text     "payment_details"
    t.string   "auth_code"
    t.string   "transaction_id"
    t.datetime "placed_at"
    t.datetime "finalized_on"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.datetime "deleted_at"
    t.boolean  "terms"
    t.text     "comments"
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["event_item_id"], name: "index_orders_on_event_item_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "status"
    t.boolean  "published"
    t.string   "attachments"
    t.string   "check_status"
    t.text     "page_body"
    t.datetime "deleted_at"
    t.integer  "quantity"
    t.integer  "max_to_sell"
    t.decimal  "price",        precision: 9, scale: 2
    t.decimal  "tax",          precision: 6, scale: 5
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_roles_on_deleted_at"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_user_roles_on_deleted_at"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
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
    t.datetime "deleted_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "phone"
    t.string   "country"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
