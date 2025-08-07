class CreateSupplier < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false, default: ''
      t.string :code_id
      t.string :address
      t.string :email
      t.string :phone
      t.string :contact
      t.decimal :discount, precision: 8, scale: 2, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
