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

ActiveRecord::Schema[8.0].define(version: 2025_08_14_073450) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cashes", force: :cascade do |t|
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.datetime "date"
    t.boolean "cash_count", default: false, null: false
    t.string "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "code_id"
    t.decimal "credit", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "discount", precision: 4, scale: 3, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configs", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "value", default: "", null: false
    t.boolean "editable", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_configs_on_name", unique: true
  end

  create_table "contact_infos", force: :cascade do |t|
    t.string "address"
    t.string "postal_code"
    t.string "province"
    t.string "country"
    t.string "phone"
    t.string "contact"
    t.string "email"
    t.string "web"
    t.string "contactable_type"
    t.bigint "contactable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contactable_type", "contactable_id"], name: "index_contact_infos_on_contactable"
  end

  create_table "editors", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.datetime "date"
    t.decimal "base_amount", precision: 8, scale: 2, null: false
    t.decimal "total_amount", precision: 8, scale: 2, null: false
    t.decimal "vat", precision: 4, scale: 3
    t.decimal "income_retention", precision: 4, scale: 3
    t.boolean "paid", default: false, null: false
    t.bigint "client_id"
    t.bigint "supplier_id"
    t.string "type", null: false
    t.date "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["supplier_id"], name: "index_invoices_on_supplier_id"
  end

  create_table "note_lines", force: :cascade do |t|
    t.string "product_name", default: "", null: false
    t.decimal "product_price", precision: 8, scale: 2, null: false
    t.decimal "product_vat", precision: 4, scale: 3, null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "note_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_note_lines_on_note_id"
    t.index ["product_id"], name: "index_note_lines_on_product_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.datetime "date"
    t.boolean "closed", default: false, null: false
    t.bigint "client_id"
    t.bigint "supplier_id"
    t.bigint "invoice_id"
    t.string "type", null: false
    t.boolean "deposit"
    t.date "devolution_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_notes_on_client_id"
    t.index ["invoice_id"], name: "index_notes_on_invoice_id"
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
    t.bigint "invoice_id", null: false
    t.bigint "payment_type_id", null: false
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["payment_type_id"], name: "index_payments_on_payment_type_id"
  end

  create_table "product_authors", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_product_authors_on_author_id"
    t.index ["product_id"], name: "index_product_authors_on_product_id"
  end

  create_table "product_subtypes", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description"
    t.boolean "active", default: true, null: false
    t.bigint "product_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_type_id"], name: "index_product_subtypes_on_product_type_id"
  end

  create_table "product_types", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description"
    t.boolean "active", default: true, null: false
    t.bigint "vat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vat_id"], name: "index_product_types_on_vat_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "code", default: "", null: false
    t.string "name", default: "", null: false
    t.string "edition", default: "", null: false
    t.text "description"
    t.string "image_url"
    t.decimal "price", precision: 8, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.bigint "product_type_id", null: false
    t.bigint "product_subtype_id"
    t.bigint "editor_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["editor_id"], name: "index_products_on_editor_id"
    t.index ["product_subtype_id"], name: "index_products_on_product_subtype_id"
    t.index ["product_type_id"], name: "index_products_on_product_type_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "code_id"
    t.decimal "discount", precision: 4, scale: 3, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_accesses", force: :cascade do |t|
    t.string "section", default: "", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_accesses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "active", default: true, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "vats", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.decimal "rate", precision: 4, scale: 3, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "note_lines", "notes"
  add_foreign_key "note_lines", "products"
  add_foreign_key "notes", "clients"
  add_foreign_key "notes", "suppliers"
  add_foreign_key "payments", "invoices"
  add_foreign_key "payments", "payment_types"
  add_foreign_key "product_authors", "authors"
  add_foreign_key "product_authors", "products"
  add_foreign_key "product_subtypes", "product_types"
  add_foreign_key "product_types", "vats"
  add_foreign_key "products", "product_types"
  add_foreign_key "user_accesses", "users"
end
