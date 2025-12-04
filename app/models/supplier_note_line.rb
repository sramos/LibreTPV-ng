# for supplier notes, purchase product price of a book is sell price without vat
# and discount is applied to this base price, not full price.
class SupplierNoteLine < NoteLine
  def total_amount
    tax_base * (1 + product_vat)
  end

  def tax_base
    product_price * quantity * (1 - discount)
  end

  private

  def product_price_from_product
    (product.price.to_f) / (1 + self.product_rate.to_f)
  end
end
