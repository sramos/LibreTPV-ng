class CreateVats < ActiveRecord::Migration[8.0]
  def change
    create_table :vats do |t|
      t.string :name, null: false, default: ''
      t.decimal :rate, precision: 3, scale: 3, null: false, default: 0.000
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
