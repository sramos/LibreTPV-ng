module Admin
  class ProductSubtypesController < ApplicationController
    before_action :set_product_type
    before_action :set_product_subtype, only: [:edit, :update, :destroy]

    def index
      @product_subtypes = @product_type.product_subtypes.order(:name).page(params[:page]).per(session[:per_page])
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def new
      @product_subtype = ProductSubtype.new(product_type_id: @product_type.id)
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @product_subtype = ProductSubtype.new(product_type_id: @product_type.id)
      if @product_subtype.update(product_subtype_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "new_product_#{@product_type.id}_subtypes_tag",
              stream_action: :after,
              stream_locals: { product_subtype: @product_subtype },
              highlight_dom_id: "product_subtype_#{@product_subtype.id}",
            )
          end
          format.html { redirect_to admin_product_subtypes_path, notice: 'Materia/subtipo de producto creado correctamente' }
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
      if @product_subtype.update(product_subtype_params)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: helpers.update_object_turbo_stream(
              container_dom_id: "product_subtype_#{@product_subtype.id}",
              stream_locals: { product_subtype: @product_subtype },
            )
          end
          format.html { redirect_to admin_product_subtypes_path, notice: 'Materia/subtipo de producto actualizado correctamente' }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('modal', partial: 'form', locals: { product_subtype: @product_subtype })
            ]
          end
          format.html { render :edit, status: :unprocessable_entity, layout: false }
        end
      end
    end

    def destroy
      if @product_subtype.destroy
        msg = 'Materia/subtipo de producto eliminado correctamente'
      else
        msg = 'Se han producido errores eliminando la materia/subtipo de producto: ' + @product_subtype.errors.inspect
      end
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: helpers.remove_object_turbo_stream(
            container_dom_id: "product_subtype_#{@product_subtype.id}", message: msg
          )
        end
        format.html { redirect_to admin_product_subtypes_path, notice: msg }
      end
    rescue => e
      redirect_to admin_product_subtypes_path, alert: "Error al eliminar la materia/subtipo de producto: #{e.message}"
    end

    private

    def set_product_type
      @product_type = ProductType.find(params[:product_type_id])
    end
    
    def set_product_subtype
      @product_subtype = @product_type.product_subtypes.find(params[:id])
    end

    def product_subtype_params
      params.require(:product_subtype).permit(:name, :description, :active)
    end
  end
end