class OldModels::AlbaranLinea < OldModels 
  belongs_to :producto
  belongs_to :albaran
 
  has_one :linea_descuento, :foreign_key => :linea_descuento_id, :class_name => "AlbaranLinea", :dependent => :destroy

  def self.migrate
    all.each do |obj|
      obj.migrate_object
    end
  end

  def migrate_object
    note = OldModelsMap.find_by(old_object: albaran)
    if note.nil?
      OldModels.log_error(self, "No se ha encontrado el albaran #{albaran_id} - #{albaran&.codigo}")
      return
    end
    product = OldModelsMap.find_by(old_object: producto)
    if product.nil?
      Rails.logger.warn "No se ha encontrado el producto #{producto_id} - #{producto&.codigo}"
    end
    new_obj = NoteLine.create(
      id: id,
      note_id: note.new_object_id,
      product_id: product ? product.new_object_id : nil,
      quantity: cantidad,
      discount: (descuento||0.0)/100.0,
      product_name: nombre_producto || producto&.nombre || 'N/A',
      product_price: precio_compra || precio_venta,
      product_vat: (iva||0.0)/100.0,
      created_at: created_at,
      updated_at: updated_at
    )
    OldModels.log_migration(self, new_obj)
  end

  # devuelve el subtotal (sin iva)
  def subtotal
    if ( self.albaran.proveedor_id )
      precio = self.precio_compra
    else
      precio = self.precio_venta / (1 + self.iva.to_f/100)
      #precio = self.producto.precio / (1 + self.producto.familia.iva.valor.to_f/100)
    end
    return precio * self.cantidad * (1 - self.descuento.to_f/100)
  end

  # devuelve el total (con iva)
  def total
    if ( self.albaran.proveedor_id )
      precio = self.precio_compra * (1 + self.iva.to_f/100)
    else
      precio = self.precio_venta
      #precio = self.producto.precio
    end
    return precio * self.cantidad * (1 - self.descuento.to_f/100)
  end

  # genera una linea de descuento en base a la presente
  def nueva_linea_descuento
    if self.albaran.cliente && self.producto && self.linea_descuento.nil?
      credito = self.albaran.cliente.credito_acumulado
      descontar = self.total > credito ? credito : self.total
      AlbaranLinea.create(:albaran_id => self.albaran_id, :cantidad => 1,
        :nombre_producto => "Descuento " + self.nombre_producto,
        :iva => self.producto.familia.iva.valor, :precio_venta => 0-descontar,
	:linea_descuento_id => self.id )
    end
  end
end
