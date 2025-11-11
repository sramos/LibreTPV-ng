class OldModels::Proveedor < OldModels
  has_many :albarans
  has_many :facturas

  def self.migrate
    all.each do |obj|
      new_obj = Supplier.create(
        name: obj.nombre,
        code_id: obj.cif || '',
        discount: obj.descuento || 0,
        active: true,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      if new_obj.errors.empty?
        ContactInfo.create(
          contactable: new_obj,
          email: obj.email || '',
          phone: obj.telefono || '',
          address: obj.direccion || '',
          created_at: obj.created_at,
          updated_at: obj.updated_at
        )
      end
      OldModels.log_migration(obj, new_obj)
    end
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
