class Config < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def self.value(name)
    config = Config.find_by(name: name)
    config.value if config
  end

  def self.next_invoice_code
    (Config.value('COMPANY_INVOICES_PREFIX')||'') + format("%010d", Config.next_invoice_number.to_s)
  end

  def self.next_invoice_number
    config = Config.find_or_create_by(name: 'COMPANY_INVOICES_COUNT') do |c|
      c.value = 0
    end
    value = config.value.blank? ? 0 : config.value.to_i
    config.update value: value + 1
    config.value
  end
end
