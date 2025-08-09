class CreateEditors < ActiveRecord::Migration[8.0]
  def change
    create_table :editors do |t|
      t.string :name, null: false, default: ''
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
