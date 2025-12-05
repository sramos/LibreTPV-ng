require 'test_helper'

class FindProductTtlServiceTest < ActiveSupport::TestCase
  test 'returns Manifiesto Comunista for known ISBN' do
    result = FindProduct::TtlService.call('9788499425597')
    assert result.success?, 'Expected TTL service to succeed'
    assert_equal 'EL MANIFIESTO COMUNISTA', result.payload[:title].upcase
    assert_equal 'Engels, Friedrich', result.payload[:authors].first
    assert_equal 'Marx, Karl', result.payload[:authors].last
  end
end
