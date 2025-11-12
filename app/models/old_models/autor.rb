class OldModels::Autor < OldModels 
  has_many :autor_x_producto
  has_many :producto, through: :autor_x_producto

  def self.migrate
    all.each do |obj|
      obj.migrate_object
    end
  end

  def migrate_object
    new_obj = Author.create(
      name: self.nombre,
      active: true,
      created_at: self.created_at,
      updated_at: self.updated_at
    )
    if self.nombre && new_obj.errors[:name].present?
      new_obj = Author.find_by(name: self.nombre)
    end
    OldModels.log_migration(self, new_obj)
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
