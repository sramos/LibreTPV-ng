class OldModels::ProductoEditorialXAlmacen < OldModels 
  belongs_to :producto_editorial
  has_one :producto, through: :producto_editorial
  belongs_to :almacen
end
