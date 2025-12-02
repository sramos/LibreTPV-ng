class OldModels::FormaPago < OldModels 
  has_many :pago

  def self.migrate
    all.each do |obj|
      new_obj = PaymentType.create(
        id: obj.id,
        name: obj.nombre,
        cash: obj.caja,
        active: true,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      OldModels.log_migration(obj, new_obj)
    end
  end
end
