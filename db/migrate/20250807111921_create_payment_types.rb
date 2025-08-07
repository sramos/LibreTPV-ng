class CreatePaymentTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_types do |t|
      t.string :name, null: false, default: ''
      t.string :description
      t.boolean :cash, null: false, default: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
