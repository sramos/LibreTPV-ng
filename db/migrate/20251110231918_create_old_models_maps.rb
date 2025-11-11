class CreateOldModelsMaps < ActiveRecord::Migration[8.0]
  def change
    create_table :old_models_maps do |t|
      t.belongs_to :old_object, polymorphic: true
      t.belongs_to :new_object, polymorphic: true
    end
  end
end
