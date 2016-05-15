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

ActiveRecord::Schema.define(version: 20160325134122) do

  create_table "admins", force: :cascade do |t|
    t.string   "username", limit: 255
    t.string   "password", limit: 255
    t.datetime "created"
    t.datetime "modified"
  end

  create_table "awb_airwaybills", force: :cascade do |t|
    t.integer  "airway_bill",             limit: 8
    t.string   "from_name",               limit: 255
    t.string   "from_company_name",       limit: 255
    t.text     "from_address",            limit: 65535
    t.string   "from_city",               limit: 100
    t.string   "from_state",              limit: 100
    t.string   "from_zipcode",            limit: 15
    t.string   "from_country",            limit: 100
    t.string   "from_kyc",                limit: 255
    t.text     "from_phone",              limit: 65535
    t.text     "from_email",              limit: 65535
    t.string   "to_name",                 limit: 255
    t.string   "to_company_name",         limit: 255
    t.text     "to_address",              limit: 65535
    t.string   "to_city",                 limit: 100
    t.string   "to_state",                limit: 100
    t.string   "to_zipcode",              limit: 15
    t.string   "to_country",              limit: 100
    t.string   "to_kyc",                  limit: 255
    t.text     "to_phone",                limit: 65535
    t.text     "to_email",                limit: 65535
    t.string   "booking_name",            limit: 255
    t.string   "booking_company_name",    limit: 255
    t.string   "booking_phone",           limit: 255
    t.string   "booking_email",           limit: 255
    t.string   "network",                 limit: 255
    t.string   "service",                 limit: 255
    t.integer  "pcs",                     limit: 4
    t.text     "weight",                  limit: 65535
    t.text     "dimensions",              limit: 65535
    t.integer  "shipment_type",           limit: 1,                 null: false
    t.integer  "shipment_mode",           limit: 1,                 null: false
    t.float    "invoice_value",           limit: 53,                null: false
    t.string   "invoice_value_currency",  limit: 5,                 null: false
    t.integer  "apply_fov",               limit: 1,     default: 0, null: false
    t.float    "fov_amount",              limit: 53
    t.string   "content_details",         limit: 255
    t.string   "special_instructions",    limit: 255
    t.text     "uploaded_files",          limit: 65535
    t.string   "dispatch_forwarder_name", limit: 255
    t.string   "dispatch_docit_no",       limit: 255
    t.string   "dispatch_telephone_no",   limit: 255
    t.date     "dispatch_date"
    t.integer  "status",                  limit: 1,                 null: false
    t.datetime "created",                                           null: false
  end

  create_table "cis_airwaybills", force: :cascade do |t|
    t.string   "net_no",            limit: 25
    t.integer  "awb_no",            limit: 8
    t.string   "bnet_cd",           limit: 10
    t.string   "bservice_cd",       limit: 10
    t.string   "sec_cd",            limit: 10
    t.date     "booking_date"
    t.string   "cln_cd",            limit: 10
    t.float    "actual_wt",         limit: 24
    t.float    "vol_wt",            limit: 24
    t.integer  "no_pcs",            limit: 4
    t.datetime "delivery_datetime"
    t.string   "received_by",       limit: 255
  end

  create_table "config_list", force: :cascade do |t|
    t.string  "type",          limit: 100
    t.string  "item_name",     limit: 255
    t.string  "item_value",    limit: 255
    t.string  "group",         limit: 255
    t.integer "status",        limit: 1
    t.integer "display_order", limit: 4
  end

  create_table "destinations", force: :cascade do |t|
    t.string   "destination_name", limit: 255, null: false
    t.string   "sec_cd",           limit: 10
    t.integer  "d_type",           limit: 1
    t.string   "state",            limit: 50
    t.string   "country",          limit: 50
    t.integer  "status",           limit: 1
    t.datetime "created_at"
    t.datetime "modified_at"
  end

  create_table "networks", force: :cascade do |t|
    t.string   "network_name",   limit: 255, null: false
    t.string   "cis_net_cd",     limit: 10
    t.string   "cis_service_cd", limit: 10
    t.integer  "network_type",   limit: 1
    t.integer  "status",         limit: 1
    t.datetime "created_at"
    t.datetime "modified_at"
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "subject_class", limit: 255
    t.string   "action",        limit: 255
    t.string   "description",   limit: 255
    t.integer  "role_id",       limit: 4
    t.datetime "created_at"
    t.datetime "modified_at"
  end

  create_table "rate_masters", force: :cascade do |t|
    t.integer  "network_id",     limit: 4,                 null: false
    t.string   "name",           limit: 255,               null: false
    t.float    "fuel",           limit: 24,                null: false
    t.integer  "s_tax",          limit: 1,     default: 1, null: false
    t.float    "margin",         limit: 24,                null: false
    t.float    "margin_two",     limit: 24,                null: false
    t.integer  "margin_type",    limit: 1,                 null: false
    t.integer  "status",         limit: 1,                 null: false
    t.integer  "show_to_client", limit: 1,     default: 1
    t.text     "remarks",        limit: 65535,             null: false
    t.datetime "created_at"
    t.datetime "modified_at"
  end

  create_table "rate_query_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "user_type",  limit: 1
    t.integer  "country_id", limit: 4
    t.integer  "type",       limit: 1
    t.float    "weight",     limit: 24
    t.text     "is_session", limit: 65535
    t.datetime "created_at"
  end

  create_table "rates", force: :cascade do |t|
    t.integer  "rate_master_id", limit: 4,               null: false
    t.integer  "destination_id", limit: 4
    t.integer  "zone_id",        limit: 4
    t.float    "weight_from",    limit: 24,              null: false
    t.float    "weight_to",      limit: 24,              null: false
    t.integer  "rate",           limit: 8,               null: false
    t.integer  "rate_type",      limit: 1,               null: false
    t.integer  "service",        limit: 4,   default: 3, null: false
    t.string   "remarks",        limit: 255,             null: false
    t.datetime "created_at"
    t.datetime "modified_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "modified_at"
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
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "zone_associations", force: :cascade do |t|
    t.integer "network_id",     limit: 4, null: false
    t.integer "zone_id",        limit: 4, null: false
    t.integer "destination_id", limit: 4, null: false
  end

  create_table "zones", force: :cascade do |t|
    t.string  "zone_code",     limit: 255, null: false
    t.string  "zone_name",     limit: 255, null: false
    t.integer "display_order", limit: 4
  end

end
