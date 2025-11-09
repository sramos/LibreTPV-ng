module Admin
  class ProductTypesController < ApplicationController
    before_action :set_product_type, only: [:edit, :update, :destroy]
    before_action :form_values, only: [:new, :edit]

    def index
      @product_types = ProductType.order(:name).page(params[:page]).per(session[:per_page])
    end

    def new
      @product_type = ProductType.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @product_type = ProductType.new(product_type_params)
      if @product_type.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: (
              helpers.update_object_turbo_stream(
                container_dom_id: 'new_product_types_tag',
                stream_action: :after,
                stream_locals: { product_type: @product_type },
                highlight_dom_id: "product_type_#{@product_type.id}",
                show_section_id: 'new_product_types_section'
              )
            )
          end
          format.html { redirect_to admin_product_types_path, notice: 'Tipo de producto creado correctamente' }
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
      if @product_type.update(product_type_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: (
              helpers.update_object_turbo_stream(
                container_dom_id: "product_type_#{@product_type.id}",
                stream_locals: { product_type: @product_type }
              )
            )
          end
          format.html { redirect_to admin_product_types_path, notice: 'Tipo de producto actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { product_type: @product_type })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @product_type.destroy
        msg = 'Tipo de producto eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando el tipo de producto: ' + @product_type.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("product_type_#{@product_type&.id}")
          ]
        end
        format.html { redirect_to admin_product_types_path, notice: msg }
      end
    rescue => e
      redirect_to admin_product_types_path, alert: "Error al eliminar el tipo de producto: #{e.message}"
    end

    private

    def set_product_type
      @product_type = ProductType.find(params[:id])
    end

    def form_values
      @vats = Vat.active.collect { |vat| [vat.name, vat.id] }
    end
    
    def product_type_params
      params.require(:product_type).permit(:name, :vat_id, :description, :active)
    end
  end
end