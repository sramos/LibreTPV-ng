class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.string :code
      t.datetime :date
      t.boolean :active, null: false, default: true
      t.references :client, foreign_key: true
      t.references :supplier, foreign_key: true
      t.timestamps
    end
  end
end
