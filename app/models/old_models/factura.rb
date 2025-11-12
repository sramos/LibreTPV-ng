class OldModels::Factura < OldModels 
  belongs_to :proveedor
  has_many :pagos
  has_many :albarans

  def self.migrate
    default_client_id = Client.first.id
    all.each do |obj|
      new_obj_data = {
        code: obj.codigo,
        date: obj.fecha, paid: obj.pagado,
        total_amount: obj.importe||0.0,
        base_amount: obj.importe_base||0.0,
        expiration_date: obj.fecha_vencimiento,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      }
      if obj.proveedor_id
        new_obj_data[:type] = 'SupplierInvoice'
        new_obj_data[:vat] = (obj.valor_iva||0.0)/100
        new_obj_data[:income_retention] = (obj.valor_irpf||0.0)/100
        supplier = OldModelsMap.find_by(old_object: obj.proveedor)
        if supplier.nil?
          OldModels.log_error(obj, "No se ha encontrado el proveedor #{obj.proveedor_id} - #{obj.proveedor&.nombre}")
          next
        end
        new_obj_data[:supplier_id] = supplier.new_object_id
      else
        new_obj_data[:type] = 'ClientInvoice'
        client = OldModelsMap.find_by(old_object: obj.albarans.first&.cliente)
        if client.nil?
          Rails.logger.warn "No se ha encontrado el cliente #{obj.albarans.first&.cliente_id} - #{obj.albarans.first&.cliente&.nombre}"
          new_obj_data[:client_id] = default_client_id
        else
          new_obj_data[:client_id] = client.new_object_id
        end
      end
      new_obj = Invoice.create(new_obj_data)
      if new_obj.errors[:code].present?
        new_obj.code += " (D/#{obj.id})"
        new_obj.save
      end
      OldModels.log_migration(obj, new_obj)
    end
  end

  # devuelve el codigo de la factura o el del albaran si no existe
  def codigo_mayusculas
    (self.codigo == "N/A" && self.albarans.first && self.albarans.first.codigo != "") ? "(*) " + self.albarans.first.codigo.upcase : self.codigo.upcase
  end

  # devuelve el importe pendiente de pago
  def pago_pendiente
    pago_pendiente = self.importe
    self.pagos.each { |pago| pago_pendiente -= pago.importe }
    return pago_pendiente
  end

  # devuelve el debe de una factura
  def debe
    if (!self.albarans.empty? && ( (self.albarans.first.proveedor_id && self.importe >= 0) || (self.albarans.first.cliente_id && self.importe < 0))) || (self.proveedor && self.importe >= 0)
      return self.importe.abs
    else
      return nil 
    end
  end

  # devuelve el haber de una factura
  def haber
    if (!self.albarans.empty? && ( (self.albarans.first.cliente_id && self.importe >= 0) || (self.albarans.first.proveedor_id && self.importe <0))) || (self.proveedor && self.importe < 0)
      return self.importe.abs
    else
      return nil 
    end
  end

  # devuelve el concepto de una factura
  def concepto
    unless (self.albarans.nil?)
      if self.albarans.first.cliente_id
        concepto = (self.importe>=0?"Venta ":"Devolucion ") + self.albarans.first.cliente.nombre
      else
        concepto = (self.importe>=0?"Compra ":"Devolucion compra ") + self.albarans.first.proveedor.nombre
      end
    else
      concepto = (self.importe>0?"Factura ":"Cobro ") + (self.proveedor ? self.proveedor.nombre : "REVISAME!!!")
      #concepto = (importe>0?"Factura ":"Cobro ") + "REVISAME"
    end
    return concepto
  end

  # devuelve el nombre del cliente o el proveedor (si el albaran asociado esta vinculado a uno)
  def albaran_cliente_nombre
    albarans.joins(:cliente).pluck("clientes.nombre").first
  end
  def albaran_proveedor_nombre
    albarans.joins(:proveedor).pluck("proveedors.nombre").first
  end

  # devuelve la base imponible tenga o no un albaran asociado
  def base_imponible
    # Si hay un iva asociado a la factura completa (aunque sea 0)
    if ( self.valor_iva )
      return self.importe / (1 + (valor_iva.to_f - valor_irpf.to_f)/100 )
    # Si la factura corresponde a un albaran 
    elsif !self.albarans.empty?
      return self.importe_base ? self.importe_base : self.albarans.inject(0) { |val,alb| val + alb.base_imponible }
    end
  end

  # modifica la base imponible
  def base_imponible=(valor)
    self.importe_base = valor.to_f
    if ( self.valor_iva )
      self.importe = valor.to_f * (1 + (valor_iva.to_f - valor_irpf.to_f )/100 )
    else
      self.importe=valor.to_f
    end
  end

  # devuelve el irpf
  def irpf
    return self.base_imponible.abs * self.valor_irpf.to_f/100
  end

  # devuelve el iva aplicado
  def iva_aplicado
    if ( self.valor_iva )
      return self.base_imponible.abs * self.valor_iva.to_f/100
    else
      return self.importe - self.base_imponible
    end
  end

  # devuelve el iva aplicado desglosado segun tipos
  def desglose_por_iva
    if ( self.valor_iva )
      return { self.valor_iva.to_s => [self.base_imponible ,self.base_imponible.abs * self.valor_iva.to_f/100, self.importe] }
    else
      total = {}
      self.albarans.each do |alb|
        alb.desglose_por_iva.each do |key,values| 
          if total[key]
            total[key] = total[key].zip(values).map {|a| a.inject(:+)}
          else
            total[key] = values
          end  
        end
      end
      return total 
    end
  end
end
