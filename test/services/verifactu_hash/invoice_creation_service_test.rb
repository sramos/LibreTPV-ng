require 'test_helper'
require 'ostruct'

class VerifactuHash::InvoiceCreationServiceTest < ActiveSupport::TestCase
  def setup
    @emisor_code = 'A12345678'
    @invoice = create_test_invoice
    @previous_hash = 'abc123def456'
  end

  test 'generates hash with all required invoice creation fields' do
    result = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, @previous_hash)
    
    assert result.success?, 'Expected service to succeed'
    assert_not_nil result.payload, 'Expected hash payload'
    assert result.payload.is_a?(String), 'Expected payload to be a string'
    assert_equal 64, result.payload.length, 'Expected SHA256 hash length'
  end

  test 'includes correct fields in hash generation' do
    result = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, @previous_hash)
    
    assert result.success?, 'Expected service to succeed'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Test that the service processes the expected fields by verifying
    # different inputs produce different hashes
    different_invoice = create_test_invoice(code: 'DIFF-001')
    result2 = VerifactuHash::InvoiceCreationService.call(@emisor_code, different_invoice, @previous_hash)
    assert_not_equal result.payload, result2.payload, 'Different invoices should produce different hashes'
  end

  test 'handles nil previous hash gracefully' do
    result = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, nil)
    
    assert result.success?, 'Expected service to succeed with nil previous hash'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Test that nil and empty string produce same result
    result_empty = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, '')
    assert_equal result.payload, result_empty.payload, 'Nil and empty previous hash should produce same result'
  end

  test 'generates different hash for different invoices' do
    invoice2 = create_test_invoice(code: 'INV-2024-002', date: Date.new(2024, 1, 16))
    
    result1 = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, @previous_hash)
    result2 = VerifactuHash::InvoiceCreationService.call(@emisor_code, invoice2, @previous_hash)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different invoices'
  end

  test 'generates different hash for different emisor codes' do
    different_emisor = 'B87654321'
    
    result1 = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, @previous_hash)
    result2 = VerifactuHash::InvoiceCreationService.call(different_emisor, @invoice, @previous_hash)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different emisor codes'
  end

  test 'generates different hash for different previous hash' do
    different_previous = 'xyz789uvw456'
    
    result1 = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, @previous_hash)
    result2 = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, different_previous)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different previous hash'
  end

  test 'handles invoice with zero amounts' do
    zero_invoice = create_test_invoice(total_vat: 0, total_amount: 0)
    
    result = VerifactuHash::InvoiceCreationService.call(@emisor_code, zero_invoice, @previous_hash)
    
    assert result.success?, 'Expected service to succeed with zero amounts'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Verify zero values produce different hash than non-zero values
    result_nonzero = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, @previous_hash)
    assert_not_equal result.payload, result_nonzero.payload, 'Zero and non-zero amounts should produce different hashes'
  end

  test 'returns failure when invoice is nil' do
    result = VerifactuHash::InvoiceCreationService.call(@emisor_code, nil, @previous_hash)
    
    assert result.failure?, 'Expected service to fail with nil invoice'
    assert_not_nil result.error, 'Expected error object'
    assert_kind_of NoMethodError, result.error, 'Expected NoMethodError for nil invoice'
  end

  private

  def create_test_invoice(code: 'INV-2024-001', date: Date.new(2024, 1, 15), total_vat: 21.0, total_amount: 121.0)
    OpenStruct.new(
      code: code,
      date: date,
      type_code: 'F1',
      total_vat: total_vat,
      total_amount: total_amount,
      created_at: Time.new(2024, 1, 15, 10, 30, 0, '+00:00')
    )
  end
end
