require 'helper'

class TestTemplates < Minitest::Test
  def test_location_is_memoized
    assert_equal Gem2Rpm::Templates.location.object_id, Gem2Rpm::Templates.location.object_id
  end
end
