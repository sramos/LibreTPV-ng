class OldModels::Autor < OldModels 
  has_many :autor_x_producto
  has_many :producto, through: :autor_x_producto

  def self.migrate
    all.each do |obj|
      new_obj = Author.create(
        name: obj.nombre,
        active: true,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      OldModels.log_migration(obj, new_obj)
    end
  end
  
  # Renombra a un autor (si ya existe alguno con el nombre propuesto, mueve los libros al nuevo)
  def renombra nuevo_nombre=nil, reasigna_productos=false
    nuevo_nombre = sanea_nombre(nuevo_nombre)
    if nuevo_nombre && self.nombre != nuevo_nombre
      # Busca si existe ya algun autor con ese nombre
      existente = Autor.find_by_nombre nuevo_nombre
      # Si ya existe el autor, 
      if existente && reasigna_productos
        autor_x_producto.update_all(autor_id: existente.id)
        self.destroy
      else
        self.update_attributes(nombre: nuevo_nombre) 
      end
    end 
  end
end
