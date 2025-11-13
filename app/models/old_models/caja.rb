class OldModels::Caja < OldModels
  def self.migrate
    all.each do |obj|
      obj.migrate_object
    end
  end

  def migrate_object
    new_obj = Cash.create(
      amount: self.importe,
      date: self.fecha_hora,
      cash_count: self.cierre_caja||false,
      comments: self.comentarios,
      created_at: self.created_at,
      updated_at: self.updated_at
    )
    OldModels.log_migration(self, new_obj)
  end
end
