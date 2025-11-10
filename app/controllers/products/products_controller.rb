module Products 
  class ProductsController < ApplicationController
    before_action :set_product, only: [:edit, :update, :destroy]

    def index
      @products = Product.order(:name).page(params[:page]).per(session[:per_page])
    end

    def new
      @product = Product.new
      respond_to do |format|
        format.html { render layout: false }
        format.turbo_stream
      end
    end

    def create
      @product = Product.new(product_params)
      if @product.save
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
          render turbo_stream: [
            turbo_stream.remove("product_#{@product&.id}")
          ]
        end
        format.html { redirect_to products_products_path, notice: msg }
      end
    rescue => e
      redirect_to products_products_path, alert: "Error al eliminar el producto: #{e.message}"
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :active)
    end
  end
end