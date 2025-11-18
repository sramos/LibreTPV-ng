class ProductsController < ApplicationController

  # Methos used in both sales and products sections
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
end