class OldModels::Materia < OldModels 
  has_many :producto
  belongs_to :familia

  def self.migrate
    all.each do |obj|
      product_type = OldModelsMap.find_by(old_object: obj.familia)
      if product_type.nil?
        OldModels.log_error(obj, "No se ha encontrado el tipo de producto #{obj.id} - #{obj.familia&.nombre}")
        next
      end
      new_obj = ProductSubtype.create(
        id: obj.id,
        name: obj.nombre,
        product_type_id: product_type.new_object_id,
        active: true,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      OldModels.log_migration(obj, new_obj)
    end
  end
end
