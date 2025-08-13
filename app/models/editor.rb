class Editor < ApplicationRecord
  has_many :products

  validates :name, presence: true, uniqueness: true
  before_validation :prepare_clean_up_name
  before_destroy :validate_destroy, prepend: true

  private

  def validate_destroy
    if products.any?
      errors.add(:base, 'No se puede eliminar un editor que tenga productos')
      throw :abort
    end
  end

  def prepare_clean_up_name
    self.name = clean_up_name(name)
  end

  def clean_up_name(the_name)
    if the_name.present?
      the_name.strip!
      the_name.upcase!
    end
    the_name
  end
end
