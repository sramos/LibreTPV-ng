class CreateCash < ActiveRecord::Migration[8.0]
  def change
    create_table :cashes do |t|
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.datetime :date
      t.boolean :cash_count, null: false, default: false
      t.string :comments
      t.timestamps
    end
  end
end
