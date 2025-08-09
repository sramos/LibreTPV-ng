class CreateContactInfo < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_infos do |t|
      t.string :address
      t.string :postal_code
      t.string :province
      t.string :country
      t.string :phone
      t.string :contact
      t.string :email
      t.string :web
      t.references :contactable, polymorphic: true
      t.timestamps
    end
  end
end
