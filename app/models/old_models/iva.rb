class OldModels::Iva < OldModels 
  has_many :familia

  def self.migrate
    all.each do |obj|
      new_obj = Vat.create(
        name: obj.nombre,
        rate: obj.valor/100.0,
        active: true,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      OldModels.log_migration(obj, new_obj)
    end
  end
end
