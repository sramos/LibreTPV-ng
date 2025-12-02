class OldModels::Familia < OldModels 
  belongs_to :iva
  has_many :producto
  has_many :materia
  belongs_to :campo

  def self.migrate
    all.each do |obj|
      vat = OldModelsMap.find_by(old_object: obj.iva)
      new_obj = ProductType.create(
        id: obj.id,
        name: obj.nombre,
        vat_id: vat.new_object_id,
        active: true,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      OldModels.log_migration(obj, new_obj)
    end
  end

  # Devuelve el id de la materia por defecto para la familia
  def materia_defecto_id
    materia_defecto = materia.find_by_valor_defecto(true)
    return materia_defecto.id if materia_defecto
  end
end
