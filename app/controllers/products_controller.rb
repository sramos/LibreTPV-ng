class ProductsController < ApplicationController
  #before_action :set_product, only: [:show, :edit, :create, :update, :destroy]

  def index
    filter_products
  end

  private

  def filter_products
    @products = Product.all
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :stock, :product_type_id, :product_subtype_id, :editor_id)
  end
end