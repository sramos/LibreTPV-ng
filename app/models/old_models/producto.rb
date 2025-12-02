class OldModels::Producto < OldModels

  belongs_to :familia
  belongs_to :materia
  belongs_to :editorial
  has_many :albaran_linea
  has_one :producto_editorial
  has_one :relacion_web, as: :elemento

  has_many :autor_x_producto, dependent: :destroy
  has_many :autor, through: :autor_x_producto

  def self.migrate
    all.each do |obj|
      product_type = OldModelsMap.find_by(old_object: obj.familia)
      if product_type.nil?
        OldModels.log_error(obj, "No se ha encontrado el tipo de producto #{obj.id} - #{obj.familia&.nombre}")
        next
      end
      product_subtype = OldModelsMap.find_by(old_object: obj.materia)
      if product_subtype.nil?
        Rails.logger.warn "No se ha encontrado el subtipo de producto para materia #{obj.materia_id} - #{obj.materia&.nombre}"
        product_subtype = OldModelsMap.find_by(old_object: obj.familia.materia.find_by(valor_defecto: true))
      end
      if obj.editorial
        publisher = OldModelsMap.find_by(old_object: obj.editorial)
        if publisher.nil?
          OldModels.log_error(obj, "No se ha encontrado la editorial #{obj.editorial_id} - #{obj.editorial&.nombre}")
          next
        end
      end
      code = OldModels::Producto.check_code(obj.codigo)
      new_obj = Product.create(
        id: obj.id,
        name: obj.nombre,
        code: code,
        description: obj.descripcion,
        product_type_id: product_type.new_object_id,
        product_subtype_id: product_subtype&.new_object_id,
        price: obj.precio,
        stock: obj.cantidad,
        publisher_id: publisher&.new_object_id,
        edition: obj.anno,
        created_at: obj.created_at,
        updated_at: obj.updated_at
      )
      if new_obj.errors.empty?
        obj.autor_x_producto.each do |autor_x_producto|
          autor = OldModelsMap.find_by(old_object: autor_x_producto.autor)
          if autor.nil?
            OldModels.log_error(obj, "No se ha encontrado el autor #{autor_x_producto.autor_id} - #{autor_x_producto.autor&.nombre}")
            next
          end
          new_obj.product_authors.create(
            author_id: autor.new_object_id,
          )
        end
      end
      OldModels.log_migration(obj, new_obj)
    end
  end
  def self.check_code(code)
    if Product.find_by(code: code)
      code = self.check_code("D/#{code}")
    end
    return code
  end

end
