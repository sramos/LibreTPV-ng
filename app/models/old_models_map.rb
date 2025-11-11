class OldModelsMap < ApplicationRecord
  belongs_to :old_object, polymorphic: true
  belongs_to :new_object, polymorphic: true
end
