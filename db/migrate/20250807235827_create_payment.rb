class CreatePayment < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.datetime :date
      t.references :invoice, null: false, foreign_key: true
      t.references :payment_type, null: false, foreign_key: true
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.timestamps
    end
  end
end
