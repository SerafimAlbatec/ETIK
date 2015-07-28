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

ActiveRecord::Schema.define(version: 20150722074727) do

  create_table "cat_tzamia", force: true do |t|
    t.text     "name"
    t.text     "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "colors", force: true do |t|
    t.string   "image"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.integer  "katigoria"
    t.float    "mia_pleura",   limit: 24
    t.float    "duo_pleura",   limit: 24
    t.text     "sungate_in"
    t.text     "sungate_out"
    t.text     "sungate_both"
  end

  create_table "constructors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "eksoterikas", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epikathimenos", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "istorikos", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leafs", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lines", force: true do |t|
    t.text     "name"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "epivarinsi_line",     limit: 24
    t.float    "epivarinsi_lastixo",  limit: 24
    t.text     "koimeno"
    t.text     "name_allo"
    t.integer  "yes"
    t.text     "direct_img"
    t.text     "sungate_description"
    t.text     "sungate_code"
  end

  create_table "material_constructors", force: true do |t|
    t.integer  "material_id"
    t.integer  "constructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "materials", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_categorie_leafs", force: true do |t|
    t.integer  "open_categorie_id"
    t.integer  "leaf_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_categories", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_types", force: true do |t|
    t.string   "name"
    t.integer  "max_height"
    t.integer  "min_height"
    t.integer  "max_width"
    t.integer  "min_width"
    t.string   "image"
    t.integer  "leaf_id"
    t.integer  "open_categorie_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "code",              limit: 24
    t.integer  "order"
  end

  create_table "orders", force: true do |t|
    t.integer  "user_id"
    t.text     "open_categorie_id"
    t.text     "material_id"
    t.text     "constructor_id"
    t.text     "system_id"
    t.text     "line_id"
    t.integer  "leaf_id"
    t.text     "main_color_id"
    t.text     "leaf_color_id"
    t.text     "right_color_id"
    t.text     "left_color_id"
    t.text     "up_color_id"
    t.text     "down_color_id"
    t.text     "open_type_id"
    t.float    "width",                      limit: 24
    t.float    "height",                     limit: 24
    t.float    "price",                      limit: 24
    t.float    "price_extra",                limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "posotoita"
    t.string   "rolo"
    t.string   "color_rolou"
    t.float    "xwrisma1",                   limit: 24
    t.float    "xwrisma2",                   limit: 24
    t.float    "xwrisma3_1",                 limit: 24
    t.float    "xwrisma3_2",                 limit: 24
    t.float    "xwrisma3_3",                 limit: 24
    t.string   "persida"
    t.string   "color_persidas"
    t.float    "price_update",               limit: 24
    t.float    "price_sum",                  limit: 24
    t.float    "price_new",                  limit: 24
    t.float    "height_new",                 limit: 24
    t.integer  "lastixo"
    t.text     "profil_panw"
    t.text     "profil_katw"
    t.text     "profil_deksia"
    t.text     "profil_aristera"
    t.integer  "posotita_p"
    t.integer  "posotita_k"
    t.integer  "posotita_d"
    t.integer  "posotita_a"
    t.text     "tzamia"
    t.text     "typos"
    t.text     "color_typos"
    t.text     "image"
    t.text     "odoigos"
    t.text     "color_odoigou"
    t.integer  "in_out"
    t.integer  "pse"
    t.text     "color_profil_d"
    t.text     "color_profil_a"
    t.text     "color_profil_p"
    t.text     "color_profil_k"
    t.float    "width_new",                  limit: 24
    t.integer  "istoriko_id"
    t.float    "price_rolou",                limit: 24
    t.float    "price_odoigou",              limit: 24
    t.float    "price_persidas",             limit: 24
    t.float    "price_tzamiou",              limit: 24
    t.float    "price_profil",               limit: 24
    t.float    "price_tupou",                limit: 24
    t.string   "canvas"
    t.float    "xwrisma_y_1",                limit: 24
    t.float    "xwrisma_y_2",                limit: 24
    t.text     "profil_deksia_1"
    t.text     "profil_deksia_2"
    t.text     "profil_deksia_3"
    t.integer  "profil_deksia_arithmos_1"
    t.integer  "profil_deksia_arithmos_2"
    t.integer  "profil_deksia_arithmos_3"
    t.float    "timi_profil_deksia_1",       limit: 24
    t.float    "timi_profil_deksia_2",       limit: 24
    t.float    "timi_deksia_profil_3",       limit: 24
    t.text     "profil_aristera_1"
    t.text     "profil_aristera_2"
    t.text     "profil_aristera_3"
    t.integer  "profil_aristera_arithmos_1"
    t.integer  "profil_aristera_arithmos_2"
    t.integer  "profil_aristera_arithmos_3"
    t.float    "timi_profil_aristera_1",     limit: 24
    t.float    "timi_profil_aristera_2",     limit: 24
    t.float    "timi_profil_aristera_3",     limit: 24
    t.text     "profil_panw_1"
    t.text     "profil_panw_2"
    t.text     "profil_panw_3"
    t.integer  "profil_panw_arithmos_1"
    t.integer  "profil_panw_arithmos_2"
    t.text     "profil_panw_arithmos_3"
    t.float    "timi_profil_panw_1",         limit: 24
    t.float    "timi_profil_panw_2",         limit: 24
    t.float    "timi_profil_panw_3",         limit: 24
    t.text     "profil_katw_1"
    t.text     "profil_katw_2"
    t.text     "profil_katw_3"
    t.integer  "profil_katw_arithmos_1"
    t.integer  "profil_katw_arithmos_2"
    t.integer  "profil_katw_arithmos_3"
    t.float    "timi_profil_katw_1",         limit: 24
    t.float    "timi_profil_katw_2",         limit: 24
    t.float    "timi_profil_katw_3",         limit: 24
    t.text     "typos_katw_1"
    t.text     "typos_katw_2"
    t.text     "typos_katw_3"
    t.integer  "typos_katw_arithmos_1"
    t.integer  "typos_katw_arithmos_2"
    t.integer  "typos_katw_arithmos_3"
    t.float    "timi_typos_katw_1",          limit: 24
    t.float    "timi_typos_katw_2",          limit: 24
    t.float    "timi_typos_katw_3",          limit: 24
    t.integer  "paraggelia_id"
  end

  create_table "paraggelia", force: true do |t|
    t.integer  "user"
    t.integer  "customer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "done"
    t.float    "sum",        limit: 24
    t.text     "eponimo"
    t.text     "name"
    t.text     "company"
  end

  create_table "persides", force: true do |t|
    t.string   "name"
    t.float    "price",      limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pricelists", force: true do |t|
    t.integer "width"
    t.integer "height"
    t.float   "price",  limit: 24
    t.float   "code",   limit: 24
  end

  create_table "profils", force: true do |t|
    t.string   "name"
    t.float    "price",      limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
  end

  create_table "pse_users", force: true do |t|
    t.text     "name"
    t.text     "eponimo"
    t.text     "address"
    t.text     "company"
    t.text     "phone"
    t.text     "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "done"
    t.text     "user_id"
  end

  create_table "rola_colors", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profil_id",  limit: 11
  end

  create_table "rola_eksos", force: true do |t|
    t.string   "name"
    t.float    "height",       limit: 24
    t.float    "width",        limit: 24
    t.float    "price",        limit: 24
    t.integer  "rola_ekso_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rola_epiks", force: true do |t|
    t.string   "name"
    t.float    "height",          limit: 24
    t.float    "width",           limit: 24
    t.float    "price",           limit: 24
    t.integer  "epikathimeno_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roll_guides", force: true do |t|
    t.string   "name"
    t.float    "price",      limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_user_pses", force: true do |t|
    t.text     "name"
    t.text     "eponimo"
    t.text     "address"
    t.text     "company"
    t.text     "phone"
    t.text     "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.float    "done",         limit: 24
    t.integer  "cust_no"
    t.text     "mr"
    t.text     "city"
    t.integer  "postal_code"
    t.text     "country_code"
    t.text     "mobile"
    t.text     "fax"
    t.integer  "VAT"
    t.text     "dealer_num"
    t.text     "sungate_num"
  end

  create_table "system_lines", force: true do |t|
    t.integer  "system_id"
    t.integer  "line_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_open_types", force: true do |t|
    t.integer  "open_type_id"
    t.integer  "line_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "systems", force: true do |t|
    t.string   "name"
    t.integer  "constructor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "termsops", force: true do |t|
    t.text     "num"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tzamia", force: true do |t|
    t.string   "name"
    t.float    "price",         limit: 24
    t.integer  "cat_tzamia_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name"
    t.text     "epitheto"
    t.text     "company"
    t.text     "phone"
    t.text     "region"
    t.integer  "admin_id"
    t.integer  "admin"
    t.integer  "done"
    t.text     "address1"
    t.text     "address2"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.text     "sungate_name"
    t.text     "sungate_code"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
