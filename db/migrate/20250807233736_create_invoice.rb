class CreateInvoice < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.string :code, null: false, default: ''
      t.datetime :date
      t.decimal :base_amount, precision: 8, scale: 2, null: false
      t.decimal :total_amount, precision: 8, scale: 2, null: false
      t.decimal :vat, precision: 4, scale: 3
      t.decimal :income_retention, precision: 4, scale: 3
      t.boolean :paid, null: false, default: false
      t.references :client
      t.references :supplier
      t.string :type, null: false
      t.date :expiration_date

      t.timestamps
    end
  end
end
