require 'test_helper'
require 'ostruct'

class VerifactuHash::NewEventServiceTest < ActiveSupport::TestCase
  def setup
    @emisor_code = 'A12345678'
    @event = create_test_event
    @previous_hash = 'abc123def456'
    
    # Create test config values
    Config.create(name: 'SYSTEM_NIF', value: 'B12345678')
    Config.create(name: 'SYSTEM_ID', value: 'SYSTEM-001')
  end

  def teardown
    # Clean up test config values
    Config.where(name: ['SYSTEM_NIF', 'SYSTEM_ID']).delete_all
  end

  test 'generates hash with event fields' do
    result = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    
    assert result.success?, 'Expected service to succeed'
    assert_not_nil result.payload, 'Expected hash payload'
    assert result.payload.is_a?(String), 'Expected payload to be a string'
    assert_equal 64, result.payload.length, 'Expected SHA256 hash length'
  end

  test 'includes system configuration fields in hash generation' do
    result = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    
    assert result.success?, 'Expected service to succeed'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Test that different system NIF produces different hash
    Config.find_by(name: 'SYSTEM_NIF').update(value: 'C87654321')
    
    result2 = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    assert_not_equal result.payload, result2.payload, 'Different system NIF should produce different hashes'
  end

  test 'handles nil previous hash gracefully' do
    result = VerifactuHash::NewEventService.call(@emisor_code, @event, nil)
    
    assert result.success?, 'Expected service to succeed with nil previous hash'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Test that nil and empty string produce same result
    result_empty = VerifactuHash::NewEventService.call(@emisor_code, @event, '')
    assert_equal result.payload, result_empty.payload, 'Nil and empty previous hash should produce same result'
  end

  test 'generates different hash for different events' do
    event2 = create_test_event(created_at: Time.new(2024, 1, 16, 10, 30, 0, '+00:00'))
    
    result1 = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    result2 = VerifactuHash::NewEventService.call(@emisor_code, event2, @previous_hash)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different events'
  end

  test 'generates different hash for different system configuration' do
    # Test with different system NIF
    result1 = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    
    Config.find_by(name: 'SYSTEM_NIF').update(value: 'C87654321')
    
    result2 = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different system NIF'
  end

  test 'generates different hash for different previous hash' do
    different_previous = 'xyz789uvw456'
    
    result1 = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    result2 = VerifactuHash::NewEventService.call(@emisor_code, @event, different_previous)
    
    assert_not_equal result1.payload, result2.payload, 'Expected different hashes for different previous hash'
  end

  test 'returns failure when event is nil' do
    result = VerifactuHash::NewEventService.call(@emisor_code, nil, @previous_hash)
    
    assert result.failure?, 'Expected service to fail with nil event'
    assert_not_nil result.error, 'Expected error object'
    assert_kind_of NoMethodError, result.error, 'Expected NoMethodError for nil event'
  end

  test 'includes timestamp in correct format' do
    test_time = Time.new(2024, 12, 31, 23, 59, 59, '+00:00')
    event_with_custom_time = create_test_event(created_at: test_time)
    
    result = VerifactuHash::NewEventService.call(@emisor_code, event_with_custom_time, @previous_hash)
    
    assert result.success?, 'Expected service to succeed with custom timestamp'
    assert_not_nil result.payload, 'Expected hash payload'
    
    # Verify different timestamps produce different hashes
    result_original = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    assert_not_equal result.payload, result_original.payload, 'Different timestamps should produce different hashes'
  end

  test 'handles missing config gracefully' do
    # Remove config to test error handling
    Config.where(name: 'SYSTEM_NIF').delete_all
    
    result = VerifactuHash::NewEventService.call(@emisor_code, @event, @previous_hash)
    
    # Service should still succeed but with nil values
    assert result.success?, 'Expected service to succeed even with missing config'
    assert_not_nil result.payload, 'Expected hash payload'
  end

  private

  def create_test_event(created_at: Time.new(2024, 1, 15, 10, 30, 0, '+00:00'))
    OpenStruct.new(
      created_at: created_at
    )
  end
end
