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

ActiveRecord::Schema[8.0].define(version: 2025_08_07_140301) do
  create_table "clients", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "code_id"
    t.string "address"
    t.string "email"
    t.string "phone"
    t.string "contact"
    t.decimal "discount", precision: 8, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "note_lines", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "note_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_note_lines_on_note_id"
    t.index ["product_id"], name: "index_note_lines_on_product_id"
  end

  create_table "notes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "code"
    t.string "date"
    t.string "closed", default: "0", null: false
    t.bigint "client_id"
    t.bigint "supplier_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_notes_on_client_id"
    t.index ["supplier_id"], name: "index_notes_on_supplier_id"
  end

  create_table "payment_types", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description"
    t.boolean "cash", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_types", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description"
    t.boolean "active", default: true, null: false
    t.bigint "vat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vat_id"], name: "index_product_types_on_vat_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.string "name", default: "", null: false
    t.string "author"
    t.string "editor"
    t.string "year"
    t.string "description"
    t.string "image_url"
    t.decimal "price", precision: 8, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.bigint "product_type_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_type_id"], name: "index_products_on_product_type_id"
  end

  create_table "suppliers", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "code_id"
    t.string "address"
    t.string "email"
    t.string "phone"
    t.string "contact"
    t.decimal "discount", precision: 8, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vats", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.decimal "rate", precision: 8, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "note_lines", "notes"
  add_foreign_key "note_lines", "products"
  add_foreign_key "notes", "clients"
  add_foreign_key "notes", "suppliers"
  add_foreign_key "product_types", "vats"
  add_foreign_key "products", "product_types"
end
