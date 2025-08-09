class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.string :code, null: false, default: ''
      t.datetime :date
      t.boolean :active, null: false, default: true
      t.references :client, foreign_key: true
      t.references :supplier, foreign_key: true
      t.string :type, null: false
      t.boolean :deposit
      t.date :devolution_date
      t.timestamps
    end
  end
end
