class CreateNoteLines < ActiveRecord::Migration[8.0]
  def change
    create_table :note_lines do |t|
      t.string :product_name, null: false, default: ''
      t.decimal :product_price, precision: 8, scale: 2, null: false
      t.decimal :product_vat, precision: 4, scale: 3, null: false
      t.integer :quantity, null: false, default: 1
      t.references :note, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end
  end
end
