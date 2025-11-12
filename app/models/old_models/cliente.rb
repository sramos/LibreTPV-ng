class OldModels::Cliente < OldModels
  has_many :albarans

  def self.migrate
    all.each do |obj|
      obj.migrate_object
    end
  end
  def migrate_object
    new_obj = Client.create(
      name: nombre,
      code_id: cif || '',
      discount: (descuento || 0)/100.0,
      credit: credito || 0,
      active: true,
      created_at: created_at,
      updated_at: updated_at
    )
    if new_obj.errors.empty?
      ContactInfo.create(
        contactable: new_obj,
        email: email || '',
        address: direccion || '',
        postal_code: cp || '',
        created_at: created_at,
        updated_at: updated_at
      )
    end
    OldModels.log_migration(self, new_obj)
  end
end
