require 'test_helper'
require 'ostruct'

class VerifactuHashServiceTest < ActiveSupport::TestCase
  def setup
    @emisor_code = 'A12345678'
    @invoice = create_test_invoice
    @previous_hash = 'abc123def456'
  end

  test 'generates hash successfully with valid inputs' do
    service_class = Class.new(VerifactuHashService) do
      private
      
      def complete_included_fields(emisor_code, object, previous_hash)
        @included_fields['IDEmisorFactura'] = emisor_code
        @included_fields['NumSerieFactura'] = object.code
        @included_fields['FechaExpedicionFactura'] = object.date.strftime('%d-%m-%Y')
        @included_fields['Huella'] = previous_hash || ''
      end
    end

    result = service_class.call(@emisor_code, @invoice, @previous_hash)
    
    assert result.success?, 'Expected service to succeed'
    assert_not_nil result.payload, 'Expected hash payload'
    assert result.payload.is_a?(String), 'Expected payload to be a string'
    assert_equal 64, result.payload.length, 'Expected SHA256 hash length'
  end

  test 'generates different hash for different inputs' do
    service_class = Class.new(VerifactuHashService) do
      private
      
      def complete_included_fields(emisor_code, object, previous_hash)
        @included_fields['IDEmisorFactura'] = emisor_code
        @included_fields['NumSerieFactura'] = object.code
        @included_fields['Huella'] = previous_hash || ''
      end
    end

    result1 = service_class.call(@emisor_code, @invoice, @previous_hash)
    result2 = service_class.call('B87654321', @invoice, @previous_hash)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different inputs'
  end

  test 'handles empty included fields gracefully' do
    service_class = Class.new(VerifactuHashService) do
      private
      
      def complete_included_fields(emisor_code, object, previous_hash)
        # Don't add any fields
      end
    end

    result = service_class.call(@emisor_code, @invoice, @previous_hash)
    
    assert result.success?, 'Expected service to succeed'
    assert_nil result.payload, 'Expected nil payload for empty fields'
  end

  test 'handles nil previous hash' do
    service_class = Class.new(VerifactuHashService) do
      private
      
      def complete_included_fields(emisor_code, object, previous_hash)
        @included_fields['IDEmisorFactura'] = emisor_code
        @included_fields['Huella'] = previous_hash || ''
      end
    end

    result = service_class.call(@emisor_code, @invoice, nil)
    
    assert result.success?, 'Expected service to succeed with nil previous hash'
    assert_not_nil result.payload, 'Expected hash payload'
  end

  test 'returns failure when exception occurs' do
    service_class = Class.new(VerifactuHashService) do
      private
      
      def complete_included_fields(emisor_code, object, previous_hash)
        raise StandardError, 'Test error'
      end
    end

    result = service_class.call(@emisor_code, @invoice, @previous_hash)
    
    assert result.failure?, 'Expected service to fail'
    assert_not_nil result.error, 'Expected error object'
    assert_equal 'Test error', result.error.message, 'Expected specific error message'
  end

  private

  def create_test_invoice
    OpenStruct.new(
      code: 'INV-2024-001',
      date: Date.new(2024, 1, 15),
      created_at: Time.new(2024, 1, 15, 10, 30, 0, '+00:00')
    )
  end
end
