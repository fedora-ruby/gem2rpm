require 'helper'

class TestFedoraVersions < Test::Unit::TestCase

  def Gem2Rpm::template_dir
    File.join(File.dirname(__FILE__), 'templates')
  end

  def test_template_for_unavailable_version
    assert_nil Gem2Rpm::Distro.get_fedora_template_by_version(16)
    assert_nil Gem2Rpm::Distro.get_fedora_template_by_version(0)
  end

  def test_template_for_available_version
    assert Gem2Rpm::Distro.get_fedora_template_by_version(17)
    assert Gem2Rpm::Distro.get_fedora_template_by_version(177)
  end

end
