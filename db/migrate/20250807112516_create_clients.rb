class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name, null: false, default: ''
      t.string :code_id, null: false, default: ''
      t.decimal :credit, precision: 8, scale: 2, null: false, default: 0.0
      t.decimal :accumulated, precision: 8, scale: 2, null: false, default: 0.0
      t.decimal :discount, precision: 4, scale: 3, null: false, default: 0.0
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
