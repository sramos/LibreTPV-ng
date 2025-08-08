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

ActiveRecord::Schema[8.0].define(version: 2025_08_07_235827) do
  create_table "clients", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "code_id"
    t.string "address"
    t.string "email"
    t.string "phone"
    t.decimal "discount", precision: 8, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.datetime "date"
    t.decimal "total", precision: 8, scale: 2, null: false
    t.boolean "paid", default: false, null: false
    t.integer "note_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_invoices_on_note_id"
  end

  create_table "note_lines", force: :cascade do |t|
    t.string "product_name", default: "", null: false
    t.decimal "product_price", precision: 8, scale: 2, null: false
    t.decimal "product_vat", precision: 3, scale: 3, null: false
    t.integer "quantity", default: 1, null: false
    t.integer "note_id", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_note_lines_on_note_id"
    t.index ["product_id"], name: "index_note_lines_on_product_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.datetime "date"
    t.boolean "active", default: true, null: false
    t.integer "client_id"
    t.integer "supplier_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_notes_on_client_id"
    t.index ["supplier_id"], name: "index_notes_on_supplier_id"
  end

  create_table "payment_types", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description"
    t.boolean "cash", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.datetime "date"
    t.integer "invoice_id", null: false
    t.integer "payment_type_id", null: false
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["payment_type_id"], name: "index_payments_on_payment_type_id"
  end

  create_table "product_subtypes", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description"
    t.boolean "active", default: true, null: false
    t.integer "product_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_type_id"], name: "index_product_subtypes_on_product_type_id"
  end

  create_table "product_types", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description"
    t.boolean "active", default: true, null: false
    t.integer "vat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vat_id"], name: "index_product_types_on_vat_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.string "name", default: "", null: false
    t.string "author"
    t.string "editor"
    t.string "year"
    t.string "description"
    t.string "image_url"
    t.decimal "price", precision: 8, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.integer "product_type_id", null: false
    t.integer "product_subtype_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_subtype_id"], name: "index_products_on_product_subtype_id"
    t.index ["product_type_id"], name: "index_products_on_product_type_id"
  end

  create_table "suppliers", force: :cascade do |t|
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

  create_table "vats", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.decimal "rate", precision: 3, scale: 3, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "invoices", "notes"
  add_foreign_key "note_lines", "notes"
  add_foreign_key "note_lines", "products"
  add_foreign_key "notes", "clients"
  add_foreign_key "notes", "suppliers"
  add_foreign_key "payments", "invoices"
  add_foreign_key "payments", "payment_types"
  add_foreign_key "product_subtypes", "product_types"
  add_foreign_key "product_types", "vats"
  add_foreign_key "products", "product_types"
end
