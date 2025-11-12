class OldModels::AlbaranLinea < OldModels 
  belongs_to :producto
  belongs_to :albaran
 
  has_one :linea_descuento, :foreign_key => :linea_descuento_id, :class_name => "AlbaranLinea", :dependent => :destroy

  def self.migrate
    all.each do |obj|
      note = OldModelsMap.find_by(old_object: obj.albaran)
      if note.nil?
        Rails.logger.error "No se ha encontrado el albaran #{obj.albaran_id} - #{obj.albaran&.codigo}"
        next
      end
      product = OldModelsMap.find_by(old_object: obj.producto)
      if product.nil?
        Rails.logger.warn "No se ha encontrado el producto #{obj.producto_id} - #{obj.producto&.codigo}"
      end
      new_obj = NoteLine.create(
        note_id: note.new_object_id,
        product_id: product ? product.new_object_id : nil,
        quantity: obj.cantidad,
        discount: (obj.descuento||0.0)/100,
        product_name: obj.producto&.nombre,
        product_price: obj.precio_compra || obj.precio_venta,
        product_vat: (obj.iva||0.0)/100,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      OldModels.log_migration(obj, new_obj)
    end
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
