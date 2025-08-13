class Config < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def self.value(name)
    config = Config.find_by(name: name)
    config.value if config
  end

  def self.new_invoice_number
    config = Config.find_or_create_by(name: 'COMPANY_INVOICES_COUNT')
    value = config.value.blank? ? 0 : config.value.to_i
    config.update value: value + 1
    return config.value
  end
end
