class AddIsB2bToClient < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :is_b2b, :boolean, null: false, default: false
  end
end
