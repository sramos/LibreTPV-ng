class CreateSupplier < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false, default: ''
      t.string :code_id
      t.decimal :discount, precision: 3, scale: 3, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
