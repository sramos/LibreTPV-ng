class OldModels < ApplicationRecord
  # Para que no nos exija que exista una tabla en BBDD para esta clase
  self.abstract_class = true

  # Conecta con la definicion del database.yml segun el entorno en el que estamos
  establish_connection "old_models_#{Rails.env}".to_sym

  @old_models_logs = []

  # Todas las tablas son de solo lectura
  def self.readonly?
    true
  end

  def self.migrate
    OldModels::Iva.migrate unless Vat.any?
    OldModels::FormaPago.migrate unless PaymentType.any?
    OldModels::Familia.migrate unless ProductType.any?
    OldModels::Materia.migrate unless ProductSubtype.any?
    OldModels::Editorial.migrate unless Publisher.any?
    OldModels::Autor.migrate unless Author.any?
    OldModels::Proveedor.migrate unless Supplier.any?
    OldModels::Cliente.migrate unless Client.any?
    OldModels::Producto.migrate unless Product.any?
    OldModels::Factura.migrate unless Invoice.any?
    OldModels::Pago.migrate unless Payment.any?
    OldModels::Albaran.migrate unless Note.any?
    OldModels::AlbaranLinea.migrate unless NoteLine.any?
  
    puts "**** Tenemos #{@old_models_logs.count} errores en la migración" if @old_models_logs.count > 0
    @old_models_logs.each { |log| puts log }
  end

  private

  def self.log_migration obj, new_obj
    if new_obj.errors.empty?
      OldModelsMap.create(old_object: obj, new_object: new_obj)
    else
      OldModels.log_error(obj, new_obj.errors.inspect)
    end
  end
  def self.log_error obj, msg
    Rails.logger.error "Migrando #{obj.class.name} #{obj.id}: #{msg}"
    @old_models_logs << "Error #{obj.class.name} #{obj.id}: #{msg}"
  end
end
