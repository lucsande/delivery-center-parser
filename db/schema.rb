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

ActiveRecord::Schema.define(version: 2021_01_24_050934) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "contact"
    t.string "marketplace_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marketplace_id"], name: "index_customers_on_marketplace_id"
  end

  create_table "failed_order_logs", force: :cascade do |t|
    t.string "received_order_json"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "marketplace_id"
    t.bigint "store_id"
    t.float "subtotal"
    t.float "delivery_fee"
    t.float "total_shipping"
    t.float "total"
    t.string "country"
    t.string "state"
    t.string "city"
    t.string "district"
    t.string "street"
    t.string "complement"
    t.float "latitude"
    t.float "longitude"
    t.string "marketplace_creation_date"
    t.string "postal_code"
    t.integer "address_number"
    t.bigint "customer_id"
    t.string "product_quantity"
    t.string "marketplace_order_payload"
    t.boolean "processed_by_delivery_center", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["store_id"], name: "index_orders_on_store_id"
  end

  create_table "orders_payments", id: false, force: :cascade do |t|
    t.bigint "payment_id", null: false
    t.bigint "order_id", null: false
    t.index ["order_id", "payment_id"], name: "index_orders_payments_on_order_id_and_payment_id"
    t.index ["payment_id", "order_id"], name: "index_orders_payments_on_payment_id_and_order_id"
  end

  create_table "orders_products", id: false, force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "order_id", null: false
    t.index ["order_id", "product_id"], name: "index_orders_products_on_order_id_and_product_id"
    t.index ["product_id", "order_id"], name: "index_orders_products_on_product_id_and_order_id"
  end

  create_table "payment_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "payment_type_id"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_type_id"], name: "index_payments_on_payment_type_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.float "price"
    t.string "marketplace_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marketplace_id"], name: "index_products_on_marketplace_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "marketplace_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["marketplace_id"], name: "index_stores_on_marketplace_id"
  end

  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "stores"
  add_foreign_key "payments", "payment_types"
end
