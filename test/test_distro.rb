require 'helper'

class TestDistro < Minitest::Test
  def setup
    @original_default_location = Gem2Rpm::Template.default_location
    Gem2Rpm::Template.default_location = File.join(File.dirname(__FILE__), 'templates', 'fake_files')

    @original_release_files = Gem2Rpm::Distro.release_files
  end

  def teardown
    Gem2Rpm::Template.default_location = @original_default_location
    Gem2Rpm::Distro.release_files = @original_release_files
  end

  def test_get_template_for_unavailable_version
    assert_nil Gem2Rpm::Distro.template_by_os_version('foo', 16)
  end

  def test_get_template_for_available_version
    assert_equal "fedora-13-14", Gem2Rpm::Distro.template_by_os_version(Gem2Rpm::Distro::FEDORA, 13)
    assert_equal "fedora-17-rawhide", Gem2Rpm::Distro.template_by_os_version(Gem2Rpm::Distro::FEDORA, 17)
    assert_equal "fedora-17-rawhide", Gem2Rpm::Distro.template_by_os_version(Gem2Rpm::Distro::FEDORA, 177)
    assert_equal "fedora", Gem2Rpm::Distro.template_by_os_version(Gem2Rpm::Distro::FEDORA, 0)
    assert_equal "opensuse", Gem2Rpm::Distro.template_by_os_version(Gem2Rpm::Distro::OPENSUSE, 11)
  end

  def test_nature_for_unavailable_template
    Gem2Rpm::Distro.release_files = [File.join(File.dirname(__FILE__), 'templates', 'fake_files', 'unknown-release15')]

    assert_equal "default", Gem2Rpm::Distro.nature.to_s
  end

  def test_nature_for_available_template
    Gem2Rpm::Distro.release_files = [File.join(File.dirname(__FILE__), 'templates', 'fake_files', 'fedora-release17')]

    assert_equal "fedora-17-rawhide", Gem2Rpm::Distro.nature.to_s
  end

  def test_nature_for_two_release_files
    Gem2Rpm::Distro.release_files = [
      File.join(File.dirname(__FILE__), 'templates', 'fake_files', 'fedora-release15'),
      File.join(File.dirname(__FILE__), 'templates', 'fake_files', 'fedora-release17')
    ]

    assert_equal "fedora", Gem2Rpm::Distro.nature.to_s
  end

  def test_nature_for_os_release_files
    Gem2Rpm::Distro.release_files = [File.join(File.dirname(__FILE__), 'templates', 'fake_files', 'os-release')]

    assert_equal "fedora-17-rawhide", Gem2Rpm::Distro.nature.to_s
  end

  def test_release_files_is_memoized
    assert_same Gem2Rpm::Distro.release_files, Gem2Rpm::Distro.release_files
  end
end
