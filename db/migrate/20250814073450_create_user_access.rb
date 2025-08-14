class CreateUserAccess < ActiveRecord::Migration[8.0]
  def change
    create_table :user_accesses do |t|
      t.string :section, null: false, default: ''
      t.references :user, null: false, foreign_key: true
  
      t.timestamps
    end
  end
end
