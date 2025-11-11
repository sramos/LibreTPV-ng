class OldModels::Albaran < OldModels 
  has_many :albaran_lineas
  belongs_to :cliente
  belongs_to :proveedor
  belongs_to :factura
end
