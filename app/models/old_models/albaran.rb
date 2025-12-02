class OldModels::Albaran < OldModels 
  has_many :albaran_lineas
  belongs_to :cliente
  belongs_to :proveedor
  belongs_to :factura

  def self.migrate
    default_client_id = Client.first.id
    all.each do |obj|
      invoice = OldModelsMap.find_by(old_object: obj.factura)
      if obj.factura_id && invoice.nil?
        OldModels.log_error(obj, "No se ha encontrado la factura #{obj.factura_id} - #{obj.factura&.codigo}")
        next
      end
      new_obj_data = {
        id: obj.id,
        code: obj.codigo,
        date: obj.fecha||obj.created_at,
        closed: obj.cerrado,
        deposit: obj.deposito,
        invoice_id: invoice&.new_object_id,
        devolution_date: obj.fecha_devolucion,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      }
      if obj.cliente_id
        new_obj_data[:type] = 'ClientNote'
        cliente = OldModelsMap.find_by(old_object: obj.cliente)
        if cliente.nil?
          Rails.logger.warn "No se ha encontrado el cliente #{obj.cliente_id} - #{obj.cliente&.nombre}"
          new_obj_data[:client_id] = default_client_id
        else
          new_obj_data[:client_id] = cliente.new_object_id
        end
      else
        new_obj_data[:type] = 'SupplierNote'
        proveedor = OldModelsMap.find_by(old_object: obj.proveedor)
        if proveedor.nil?
          OldModels.log_error(obj, "No se ha encontrado el proveedor #{obj.proveedor_id} - #{obj.proveedor&.nombre}")
          next
        end
        new_obj_data[:supplier_id] = proveedor.new_object_id
      end
      new_obj = Note.create(new_obj_data)
      OldModels.log_migration(obj, new_obj)
    end
  end
end
