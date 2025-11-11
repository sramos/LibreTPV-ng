class OldModels::Editorial < OldModels 
  has_many :producto

  def self.migrate
    all.each do |obj|
      new_obj = Editor.create(
        name: obj.nombre || 'N/A',
        active: true,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      OldModels.log_migration(obj, new_obj)
    end
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
