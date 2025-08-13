class Author < ApplicationRecord
  include ::Sanitizable
  stripable :name
  upcaseable :name

  has_many :product_authors
  has_many :products, through: :product_authors

  validates :name, presence: true, uniqueness: true
  before_destroy :validate_destroy, prepend: true

  # Rename an author and move products if there is any with same name.
  def rename(new_name = nil, reasign_products = false)
    new_name = new_name.strip.upcase if new_name
    if new_name.present? && name != new_name
      existing_author = Author.find_by(name: new_name)
      if existing_author && reasign_products
        product_authors.update_all(author_id: existing_author.id)
        self.destroy
      else
        self.update(name: new_name)
      end
    end
  end

  private

  def validate_destroy
    if products.any?
      errors.add :base, I18n.t('errors.authors.removal_with_existing_products')
      throw :abort
    end
  end
end
