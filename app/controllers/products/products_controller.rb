module Products 
  class ProductsController < ::ProductsController
    before_action :set_product, only: [:edit, :update, :destroy, :purchases, :sales]
    before_action :set_new_product, only: [:new, :create]
    before_action :form_options, only: [:new, :edit]

    def index
      index_filtered
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'products', objects: @products.except(:limit, :offset),
                          title: 'Productos', filter_scope: filter_scope }
          nom_fich = 'productos_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
    end

    def filter
      if params[:filter] && session[filter_scope]
        session[filter_scope]['type'] = params[:filter][:type].blank? ? nil : params[:filter][:type]
        session[filter_scope]['value'] = params[:filter][:value].blank? ? nil : params[:filter][:value]
        session[filter_scope]['condition'] = params[:filter][:condition].blank? ? nil : params[:filter][:condition]
      end
      redirect_to products_products_path
    end
    
    def new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      if @product.update(product_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_products_tag',
              stream_action: :after,
              stream_locals: { product: @product },
              highlight_dom_id: "product_#{@product.id}",
              show_section_id: 'new_products_section'
            )
          end
          format.html { redirect_to admin_suppliers_path, notice: 'Proveedor creado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.update('modal', html: render_to_string(:new, layout: false, status: :unprocessable_entity))
            ]
          end
          format.html { render :new, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def edit
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def update
      if @product.update(product_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "product_#{@product.id}",
              stream_locals: { product: @product },
            )
          end
          format.html { redirect_to products_products_path, notice: 'Producto actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { product: @product })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @product.destroy
        msg = 'Producto eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el producto: ' + @product.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: helpers.remove_object_turbo_stream(
            container_dom_id: "product_#{@product.id}", message: msg
          )
        end
        format.html { redirect_to products_products_path, notice: msg }
      end
    rescue => e
      redirect_to products_products_path, alert: "Error al eliminar el producto: #{e.message}"
    end

    def purchases
      @notes = @product.supplier_notes
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'purchase_notes', objects: @notes.except(:limit, :offset),
                          title: 'Albaranes de compra' }
          nom_fich = "albaranes_compra_producto_#{@product.id}" + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def sales
      @notes = @product.client_notes
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'sale_notes', objects: @notes.except(:limit, :offset),
                          title: 'Albaranes de venta' }
          nom_fich = "albaranes_venta_producto_#{@product.id}" + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def product_type_changed
      product_type = ProductType.find_by(id: params[:product_type_id])
      @product_subtypes = product_type&.product_subtypes.order(:name).collect { |ps| [ps.name, ps.id] }
      @product = Product.new(product_type: product_type, product_subtype: product_type&.product_subtypes.default)

      render partial: 'products/products/form_product_subtype'
    end

    def find_by_isbn
      product_code = params[:product][:code].delete('-') if params[:product].present?
      
      if @product = Product.find_by(code: product_code)
        # Actualizar el header del modal con el nombre del producto encontrado
        modal_header = "Editar Producto: #{@product.name}"
      elsif product_code.present?
        result = FindProductService.call(product_code)
        if result.success?
          @product = Product.new_from_json(result.payload)
        else
          @product = Product.new(code: product_code)
        end
      end

      # Cargar las variables necesarias para el formulario
      form_options if @product.present?

      # Actualizar el header del formulario con el nombre del producto
      modal_header = @product.new_record? ? "Nuevo Producto" : "Editar Producto: #{@product.name}"
      
      # Usar TurboStream para actualizar el modal completo con el header correcto
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update('modal', 
            partial: 'products/products/form', 
            locals: { header: modal_header, product: @product })
        end
        format.html {
          render partial: 'products/products/form', locals: { product: @product }
        }
      end
    end

    private

    def index_filtered
      @filter_fields = [ ['Nombre','name','string'],
                         ['Autor','author.name','string'],
                         ['Cantidad','stock','number'],
                         #['Deposito','deposit','boolean'],
                         ['Codigo','code','string'],
                         ['Editor','publisher.name','string'],
                         ['Tipo','product_type.name','string'] ]

      @products = Product.order(:name)
      
      session[filter_scope] ||= {'type' => 'stock', 'value' => '0', 'condition' => '>'}
      value = session[filter_scope]['value'] if session[filter_scope]
      if value.present?
        case session[filter_scope]['type']
        when 'name'
          @products = @products.where("name LIKE ?", "%#{value}%")
        when 'code'
          @products = @products.where("code LIKE ?", "%#{value}%")
        when 'stock'
          operator = session[filter_scope]['condition'] if ['=','>','<'].include?(session[filter_scope]['condition'])
          @products = @products.where("stock #{operator} ?", value)
        when 'deposit'
          condition = session[filter_scope]['value'] == 'Sí' ? 'IS TRUE' : 'IS NOT TRUE'
          @products = @products.where("deposit #{condition}")
        when 'author.name'
          @products = @products.joins(:authors).where("authors.name LIKE ?", "%#{value}%")
        when 'publisher.name'
          @products = @products.joins(:publisher).where("publisher.name LIKE ?", "%#{value}%")
        when 'product_type.name'
          @products = @products.joins(:product_type).where("product_type.name LIKE ?", "%#{value}%")
        end
      end
      @products = @products.page(params[:page]).per(session[:per_page])
    end
    
    def form_options
      @product_types  = ProductType.active.order(:name).collect { |pt| [pt.name, pt.id] }
      @product_types += [ [ @product.product_type.name, @product.product_type_id ] ] if @product&.product_type&.inactive?
      @product_subtypes  = @product.product_type.product_subtypes.order(:name).collect { |ps| [ps.name, ps.id] } if @product&.product_type
      @product_subtypes += [ [ @product.product_subtype.name, @product.product_subtype_id ] ] if @product&.product_subtype&.inactive?
      @publishers  = Publisher.active.order(:name).collect { |p| [p.name, p.id] }
      @publishers += [ [ @product.publisher.name, @product.publisher_id ] ] if @product&.publisher&.inactive?
    end

    def product_params
      params.require(:product).permit(:code, :name, :description,
                                      :product_type_id,:product_subtype_id,
                                      :publisher_id, :edition,
                                      :price, :stock, :active)
    end
  end
end