class OldModels::Editorial < OldModels 
  has_many :producto

  def self.migrate
    all.each do |obj|
      obj.migrate_object
    end
  end

  def migrate_object
    new_obj = Publisher.create(
      name: self.nombre.blank? ? 'N/A' : self.nombre,
      active: true,
      created_at: self.created_at,
      updated_at: self.updated_at
    )
    OldModels.log_migration(self, new_obj)
  end

  # Renombra una editorial (si ya existe alguno con el nombre propuesto, mueve los libros al nuevo)
  def renombra nuevo_nombre=nil, reasigna_productos=false
    nuevo_nombre.strip!
    if nuevo_nombre && self.nombre != nuevo_nombre
      # Busca si existe ya alguna editorial con ese nombre
      existente = Editorial.find_by_nombre nuevo_nombre
      # Si ya existe la editorial 
      if existente && reasigna_productos
        producto.update_all(editorial_id: existente.id)
        self.destroy
      else
        self.update_attributes(nombre: nuevo_nombre)
      end
    end
  end
end
