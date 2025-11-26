require 'open-uri'

class Product < ApplicationRecord
  include ::Sanitizable
  stripable :name

  has_many :product_authors, dependent: :destroy
  has_many :authors, through: :product_authors
  has_many :note_lines
  has_many :notes, through: :note_lines
  has_many :client_notes, -> { where(type: 'ClientNote') }, source: :note, through: :note_lines
  has_many :supplier_notes, -> { where(type: 'SupplierNote') }, source: :note, through: :note_lines
  belongs_to :product_type
  belongs_to :product_subtype, optional: true
  belongs_to :publisher, optional: true
  has_one :vat, through: :product_type
  has_one_attached :image

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true
  validates :product_type, presence: true
  validates :code, presence: true, uniqueness: true

  before_destroy :validate_destroy, prepend: true

  def tax_base
    price / (1 + vat.rate)
  end

  def existing_product
    id.present? ? self : Product.find_by(name: name, code: code, price: price)
  end

  def authors_names
    authors.collect{|a| a.name}.join('; ')
  end

  def self.new_from_json(json)
    Rails.logger.info "[Product.new_from_json] Called with json: #{json.inspect}"
    return if json.blank?

    attrs = json.respond_to?(:deep_symbolize_keys) ? json.deep_symbolize_keys : json
    default_product_type = ProductType.default
    return Product.new(
      name: attrs[:title],
      code: attrs[:code],
      price: attrs[:price],
      publisher: Publisher.find_or_create_by(name: attrs[:publisher]),
      edition: attrs[:edition],
      stock: 0,
      description: attrs[:synopsis],
      image_url: attrs[:image],
      product_type: default_product_type || ProductType.first,
      product_subtype: default_product_type&.product_subtypes.default
    )
  end

  def self.create_from_json(json)
    Rails.logger.info "[Product.create_from_json] Called with json: #{json.inspect}"
    return if json.blank?

    product = Product.new_from_json(json)
    product.save

    return product if product.errors.present?

    attrs = json.respond_to?(:deep_symbolize_keys) ? json.deep_symbolize_keys : json
    product.attach_remote_image(attrs[:image]) if attrs[:image].present?

    Array(attrs[:authors]).each do |author|
      next if author.blank?
      product.authors << Author.find_or_create_by(name: author)
    end

    product
  end

  def attach_remote_image(url)
    return if url.blank?

    file = URI.open(url)
    uri_path = URI.parse(url).path
    filename = File.basename(uri_path.presence || 'cover.jpg')
    image.attach(io: file, filename: filename)
  rescue => e
    msg = "Error fetching #{url}: #{e.message}"
    Rails.logger.error "[Product.attach_remote_image] #{msg}"
    errors.add(:base, msg)
  end

  private

  def validate_destroy
    if note_lines.any?
      errors.add :base, I18n.t('errors.products.removal_with_existing_notes')
    end
    if stock > 0
      errors.add :base, I18n.t('errors.products.removal_with_stock')
    end
    throw :abort unless errors.empty?
  end
end
