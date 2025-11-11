class OldModels::Almacen < OldModels 
  has_many :producto_editorial_x_almacenes, dependent: :destroy
  has_many :productos_editorial, through: :producto_editorial_x_almacenes

  validates_presence_of :nombre, message: "El almacen debe tener un nombre."
  validates_uniqueness_of :nombre, message: "Ya existe un almacen con ese nombre."
end
