require 'helper'

class TestTemplate < Minitest::Test
  def test_default_location_is_memoized
    assert_equal Gem2Rpm::Template.location.object_id, Gem2Rpm::Template.location.object_id
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
      ), Gem2Rpm::Template.list
    assert_equal Gem2Rpm::Template.list.object_id, Gem2Rpm::Template.list.object_id
  end

  def test_list_is_memoized
    assert_equal Gem2Rpm::Template.list.object_id, Gem2Rpm::Template.list.object_id
  end
end
