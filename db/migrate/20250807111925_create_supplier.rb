class CreateSupplier < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false, default: ''
      t.string :code_id
      t.string :email
      t.string :phone
      t.decimal :discount, precision: 4, scale: 3, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
