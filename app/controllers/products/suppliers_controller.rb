module Products 
  class SuppliersController < ApplicationController
    before_action :set_supplier, only: [:edit, :update, :destroy]

    def index
      index_filtered
      @format_xls = true

      respond_to do |format|
        format.xlsx do
          @xlsx_output = {type: 'suppliers', objects: @suppliers.except(:limit, :offset),
                          title: 'Proveedores', filter_scope: filter_scope }
          nom_fich = 'proveedores_' + Time.now.strftime("%Y-%m-%d")
          render 'common_xlsx/index', xlsx: nom_fich, layout: false
        end
        format.html
      end
    end

    def new
      @supplier = Supplier.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @supplier = Supplier.new(supplier_params)
      if @supplier.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: 'new_suppliers_tag',
              stream_action: :after,
              stream_locals: { supplier: @supplier },
              highlight_dom_id: "supplier_#{@supplier.id}",
              show_section_id: 'new_suppliers_section'
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
      if @supplier.update(supplier_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "supplier_#{@supplier.id}",
              stream_locals: { supplier: @supplier },
            )
          end
          format.html { redirect_to products_suppliers_path, notice: 'Proveedor actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { supplier: @supplier })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @supplier.destroy
        msg = 'Proveedor eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el proveedor: ' + @supplier.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("supplier_#{@supplier&.id}")
          ]
        end
        format.html { redirect_to products_suppliers_path, notice: msg }
      end
    rescue => e
      redirect_to products_suppliers_path, alert: "Error al eliminar el proveedor: #{e.message}"
    end

    private

    def index_filtered
      @filter_fields = [ ['Nombre','name','string'],
                         ['Email','email','string'],
                         ['NIF','code_id','string'] ]
      @suppliers = Supplier.order(:name)

      puts "****** #{filter_scope}"
      puts "****** session[filter_scope]: #{session[filter_scope]}"
      session[filter_scope] ||= {}
      value = session[filter_scope]['value'] if session[filter_scope]
      if value.present?
        case session[filter_scope]['type']
        when 'name'
          @suppliers = @suppliers.where("name LIKE ?", "%#{value}%")
        when 'email'
          @suppliers = @suppliers.joins(:contact_info).where("contact_infos.email LIKE ?", "%#{value}%")
        when 'code_id'
          @suppliers = @suppliers.where("code_id LIKE ?", "%#{value}%")
        end
      end
      @suppliers = @suppliers.page(params[:page]).per(session[:per_page])
    end

    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    def supplier_params
      params.require(:supplier).permit(:name, :active)
    end
  end
end