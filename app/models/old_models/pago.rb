class OldModels::Pago < OldModels 
  belongs_to :factura
  belongs_to :iva
  belongs_to :forma_pago

  def self.migrate
    all.each do |obj|
      invoice = OldModelsMap.find_by(old_object: obj.factura)
      if invoice.nil?
        Rails.logger.error "No se ha encontrado la factura para #{obj.factura_id} - #{obj.factura&.codigo}"
        next
      end
      payment_type = OldModelsMap.find_by(old_object: obj.forma_pago)
      if payment_type.nil?
        Rails.logger.error "No se ha encontrado la forma de pago para #{obj.forma_pago_id} - #{obj.forma_pago&.nombre}"
        next
      end
      new_obj = Payment.create(
        invoice_id: invoice.new_object_id,
        payment_type_id: payment_type.new_object_id,
        amount: obj.importe,
        date: obj.fecha,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      OldModels.log_migration(obj, new_obj)
    end
  end
end
