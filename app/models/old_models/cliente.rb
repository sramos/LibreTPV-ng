class OldModels::Cliente < OldModels
  has_many :albarans

  def self.migrate
    all.each do |obj|
      new_obj = Client.create(
        name: obj.nombre,
        code_id: obj.cif || '',
        discount: obj.descuento || 0,
        credit: obj.credito || 0,
        active: true,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      if new_obj.errors.empty?
        ContactInfo.create(
          contactable: new_obj,
          email: obj.email || '',
          address: obj.direccion || '',
          postal_code: obj.cp || '',
          created_at: obj.created_at,
          updated_at: obj.updated_at
        )
      end
      OldModels.log_migration(obj, new_obj)
    end
  end
end
