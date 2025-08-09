class CreateProduct < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :code, null: false, default: ''
      t.string :name, null: false, default: ''
      t.string :year
      t.text :description
      t.string :image_url
      t.decimal :price, precision: 8, scale: 2, null: false
      t.integer :stock, null: false, default: 0
      t.references :product_type, null: false, foreign_key: true
      t.references :product_subtype
      t.references :editor
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
