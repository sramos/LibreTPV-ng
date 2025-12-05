require 'test_helper'

class FindProductLcdlServiceTest < ActiveSupport::TestCase
  test 'returns Manifiesto Comunista for known ISBN' do
    result = FindProduct::LcdlService.call('9788499425597')
    assert result.success?, 'Expected LCDL service to succeed'
    assert_equal 'EL MANIFIESTO COMUNISTA', result.payload[:title].upcase
    assert_equal 'Friedrich Engels', result.payload[:authors].last
    assert_equal 'Karl Marx', result.payload[:authors].first
  end
end
