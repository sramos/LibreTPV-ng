class CreateConfig < ActiveRecord::Migration[8.0]
  def change
    create_table :configs do |t|
      t.string :name, null: false, default: ''
      t.string :value, null: false, default: ''
      t.boolean :editable, null: false, default: true
      t.timestamps
    end

    add_index :configs, :name, unique: true
  end
end
