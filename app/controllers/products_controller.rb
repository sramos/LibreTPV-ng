# Methods used in both sales and products sections
class ProductsController < ApplicationController

  def search_by_name
    term = params[:q].to_s.strip
    @products = Product.where("name LIKE ?", "%#{term}%").order(stock: :desc, name: :asc).limit(10) if term.present?

    render json: @products.as_json(only: [:id, :name, :code, :stock, :price])
  end
  def search_by_code
    term = params[:q].to_s.strip
    @product = Product.find_by(code: term) if term.present?

    render json: @product.as_json(only: [:id, :name, :code, :stock, :price])
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_new_product
    default_product_type = ProductType.default
    default_product_subtype = default_product_type&.product_subtypes.default
    @product = Product.new( product_type: default_product_type,
                            product_subtype: default_product_subtype )
  end
  
end