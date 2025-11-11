class OldModels::ProductoEditorial < OldModels
  belongs_to :producto
  has_many :producto_editorial_x_almacenes
  has_many :productos_editorial, through: :producto_editorial_x_almacenes

  def cantidad
    producto_editorial_x_almacenes.sum(:cantidad)
  end
end
