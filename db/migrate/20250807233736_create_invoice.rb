class CreateInvoice < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.string :code, null: false, default: ''
      t.datetime :date
      t.decimal :total, precision: 8, scale: 2, null: false
      t.boolean :paid, null: false, default: false
      t.references :note, foreign_key: true
      t.timestamps
    end
  end
end
