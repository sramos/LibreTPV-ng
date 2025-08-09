class CreateProductAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :product_authors do |t|
      t.references :product, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true
      t.timestamps
    end
  end
end
