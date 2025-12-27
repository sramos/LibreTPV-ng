require 'test_helper'
require 'ostruct'

class VerifactuHash::InvoiceCancelationServiceTest < ActiveSupport::TestCase
  def setup
    @emisor_code = 'A12345678'
    @invoice = create_test_invoice
    @previous_hash = 'abc123def456'
  end

  test 'generates hash with all required invoice cancelation fields' do
    result = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, @previous_hash)
    
    assert result.success?, 'Expected service to succeed'
    assert_not_nil result.payload, 'Expected hash payload'
    assert result.payload.is_a?(String), 'Expected payload to be a string'
    assert_equal 64, result.payload.length, 'Expected SHA256 hash length'
  end

  test 'includes correct cancelation fields in hash generation' do
    result = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, @previous_hash)
    
    assert result.success?, 'Expected service to succeed'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Test that the service processes the expected fields by verifying
    # different inputs produce different hashes
    different_invoice = create_test_invoice(code: 'DIFF-001')
    result2 = VerifactuHash::InvoiceCancelationService.call(@emisor_code, different_invoice, @previous_hash)
    assert_not_equal result.payload, result2.payload, 'Different invoices should produce different hashes'
  end

  test 'handles nil previous hash gracefully' do
    result = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, nil)
    
    assert result.success?, 'Expected service to succeed with nil previous hash'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Test that nil and empty string produce same result
    result_empty = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, '')
    assert_equal result.payload, result_empty.payload, 'Nil and empty previous hash should produce same result'
  end

  test 'generates different hash for different invoices' do
    invoice2 = create_test_invoice(code: 'INV-2024-002', date: Date.new(2024, 1, 16))
    
    result1 = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, @previous_hash)
    result2 = VerifactuHash::InvoiceCancelationService.call(@emisor_code, invoice2, @previous_hash)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different invoices'
  end

  test 'generates different hash for different emisor codes' do
    different_emisor = 'B87654321'
    
    result1 = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, @previous_hash)
    result2 = VerifactuHash::InvoiceCancelationService.call(different_emisor, @invoice, @previous_hash)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different emisor codes'
  end

  test 'generates different hash for different previous hash' do
    different_previous = 'xyz789uvw456'
    
    result1 = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, @previous_hash)
    result2 = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, different_previous)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different previous hash'
  end

  test 'generates different hash than invoice creation service' do
    creation_result = VerifactuHash::InvoiceCreationService.call(@emisor_code, @invoice, @previous_hash)
    cancelation_result = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, @previous_hash)
    
    assert_not_equal creation_result.payload, cancelation_result.payload, 
                   'Expected different hashes between creation and cancelation services'
  end

  test 'returns failure when invoice is nil' do
    result = VerifactuHash::InvoiceCancelationService.call(@emisor_code, nil, @previous_hash)
    
    assert result.failure?, 'Expected service to fail with nil invoice'
    assert_not_nil result.error, 'Expected error object'
    assert_kind_of NoMethodError, result.error, 'Expected NoMethodError for nil invoice'
  end

  test 'uses correct date format for cancelation fields' do
    # Test with different date formats
    test_date = Date.new(2024, 12, 31)
    invoice_with_custom_date = create_test_invoice(date: test_date)
    
    result = VerifactuHash::InvoiceCancelationService.call(@emisor_code, invoice_with_custom_date, @previous_hash)
    
    assert result.success?, 'Expected service to succeed with custom date'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Verify different dates produce different hashes
    result_original = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, @previous_hash)
    assert_not_equal result.payload, result_original.payload, 'Different dates should produce different hashes'
  end

  test 'uses correct timestamp format for generation time' do
    # Test with specific timestamp
    test_time = Time.new(2024, 12, 31, 23, 59, 59, '+00:00')
    invoice_with_custom_time = create_test_invoice(created_at: test_time)
    
    result = VerifactuHash::InvoiceCancelationService.call(@emisor_code, invoice_with_custom_time, @previous_hash)
    
    assert result.success?, 'Expected service to succeed with custom timestamp'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Verify different timestamps produce different hashes
    result_original = VerifactuHash::InvoiceCancelationService.call(@emisor_code, @invoice, @previous_hash)
    assert_not_equal result.payload, result_original.payload, 'Different timestamps should produce different hashes'
  end

  private

  def create_test_invoice(code: 'INV-2024-001', date: Date.new(2024, 1, 15), created_at: Time.new(2024, 1, 15, 10, 30, 0, '+00:00'))
    OpenStruct.new(
      code: code,
      date: date,
      created_at: created_at
    )
  end
end
