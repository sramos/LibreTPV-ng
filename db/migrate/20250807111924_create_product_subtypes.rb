class CreateProductSubtypes < ActiveRecord::Migration[8.0]
  def change
    create_table :product_subtypes do |t|
      t.string :name, null: false, default: ''
      t.string :description
      t.boolean :active, null: false, default: true
      t.boolean :default, null: false, default: false
      t.references :product_type, null: false, foreign_key: true
      t.timestamps
    end
  end
end
