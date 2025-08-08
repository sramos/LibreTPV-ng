class CreateInvoice < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.string :code, null: false, default: ''
      t.datetime :date
      t.decimal :total, precision: 8, scale: 2, null: false
      t.decimal :vat, precision: 3, scale: 3
      t.decimal :tax, precision: 3, scale: 3
      t.boolean :paid, null: false, default: false
      t.references :note
      t.references :client
      t.references :supplier
      t.string :type, null: false
      t.timestamps
    end
  end
end
