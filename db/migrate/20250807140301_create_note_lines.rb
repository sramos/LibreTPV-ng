class CreateNoteLines < ActiveRecord::Migration[8.0]
  def change
    create_table :note_lines do |t|
      t.references :note, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :price, precision: 8, scale: 2, null: false
      t.timestamps
    end
  end
end
