class CreateSupplier < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false, default: ''
      t.string :code_id, null: false, default: ''
      t.decimal :discount, precision: 4, scale: 2, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
