class OldModels::Proveedor < OldModels
  has_many :albarans
  has_many :facturas

  def self.migrate
    all.each do |obj|
      obj.migrate_object
    end
  end
  def migrate_object
    new_obj = Supplier.create(
      id: id,
      name: nombre,
      code_id: cif || '',
      discount: [(descuento || 0)/100.0, 1.0].min,
      active: true,
      created_at: created_at,
      updated_at: updated_at
    )
    if new_obj.errors.empty?
      ContactInfo.create(
        contactable: new_obj,
        email: email || '',
        phone: telefono || '',
        address: direccion || '',
        created_at: created_at,
        updated_at: updated_at
      )
    end
    OldModels.log_migration(self, new_obj)
  end

  # Devuelve un array de las líneas de albaran compradas
  def productos_comprados
    albaranes = self.albarans.all :conditions => { :cerrado => true }, :order => "fecha desc"
    # Obtiene las líneas de cada albaran del proveedor
    lineas = []
    albaranes.each { |albaran| albaran.albaran_lineas.each { |linea| lineas.push(linea) } }
    return lineas
  end
end
