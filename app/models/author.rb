class Author < ApplicationRecord
  has_many :product_authors
  has_many :products, through: :product_authors

  validates :name, presence: true, uniqueness: true
  before_validation :prepare_clean_up_name
  before_destroy :validate_destroy

  # Rename an author and move products if there is any with same name.
  def rename new_name=nil, reasign_products=false
    new_name = clean_up_name(new_name)
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
      errors.add(:base, 'No se puede eliminar un autor que tenga productos')
      throw :abort
    end
  end

  def prepare_clean_up_name
    self.name = clean_up_name(name)
  end

  def clean_up_name the_name
    if the_name.present?
      the_name.strip!
      the_name.upcase!
    end
    the_name
  end
end
