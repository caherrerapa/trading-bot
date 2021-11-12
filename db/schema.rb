# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_25_224449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "balances", force: :cascade do |t|
    t.string "asset"
    t.decimal "free"
    t.decimal "locked"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["asset"], name: "index_balances_on_asset", unique: true
  end

  create_table "bots", force: :cascade do |t|
    t.decimal "minimum_price"
    t.decimal "maximum_price"
    t.integer "placed_orders_count"
    t.decimal "total_investment"
    t.decimal "entry_price"
    t.decimal "take_profit_price"
    t.boolean "use_base_asset", default: true
    t.bigint "pair_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "buy_margin_percent", default: "1.0"
    t.decimal "sell_margin_percent", default: "1.0"
    t.boolean "is_active", default: true
    t.index ["pair_id"], name: "index_bots_on_pair_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "bot_id", null: false
    t.string "exchange_order_id"
    t.string "client_order_id"
    t.decimal "price"
    t.decimal "original_quantity"
    t.decimal "executed_quantity"
    t.decimal "cumulative_quote_quantity"
    t.string "status"
    t.string "type"
    t.string "side"
    t.string "fills"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bot_id"], name: "index_orders_on_bot_id"
  end

  create_table "pairs", force: :cascade do |t|
    t.string "symbol"
    t.string "quote_asset"
    t.string "base_asset"
    t.decimal "tick_size"
    t.decimal "minimum_price"
    t.decimal "maximum_price"
    t.decimal "lot_size"
    t.decimal "minimum_size"
    t.decimal "maximum_size"
    t.decimal "minimum_notional"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["symbol"], name: "index_pairs_on_symbol", unique: true
  end

  add_foreign_key "orders", "bots"
end
