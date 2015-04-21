require 'helper'

class TestTemplates < Minitest::Test
  def test_location_is_memoized
    assert_equal Gem2Rpm::Templates.location.object_id, Gem2Rpm::Templates.location.object_id
  end

  def test_list
    assert_equal \
      %w(
        default.spec.erb
        fedora-17-18.spec.erb
        fedora-19-20.spec.erb
        fedora-21-rawhide-vagrant-plugin.spec.erb
        fedora-21-rawhide.spec.erb
        fedora.spec.erb
        opensuse.spec.erb
        pld.spec.erb
      ), Gem2Rpm::Templates.list
    assert_equal Gem2Rpm::Templates.list.object_id, Gem2Rpm::Templates.list.object_id
  end

  def test_list_is_memoized
    assert_equal Gem2Rpm::Templates.list.object_id, Gem2Rpm::Templates.list.object_id
  end
end
