class CreateContactInfo < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_infos do |t|
      t.string :address, null: false, default: ''
      t.string :postal_code, null: false, default: ''
      t.string :city, null: false, default: ''
      t.string :province, null: false, default: ''
      t.string :country, null: false, default: ''
      t.string :phone, null: false, default: ''
      t.string :contact, null: false, default: ''
      t.string :email, null: false, default: ''
      t.string :web, null: false, default: ''
      t.references :contactable, polymorphic: true
      t.timestamps
    end
  end
end
