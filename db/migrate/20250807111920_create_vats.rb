class CreateVats < ActiveRecord::Migration[8.0]
  def change
    create_table :vats do |t|
      t.string :name, null: false, default: ''
      t.decimal :rate, precision: 8, scale: 2, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
