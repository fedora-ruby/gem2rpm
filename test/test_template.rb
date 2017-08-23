require 'helper'

class TestTemplate < Minitest::Test
  def test_default_location_is_memoized
    assert_same Gem2Rpm::Template.default_location, Gem2Rpm::Template.default_location
  end

  def test_list
    assert_equal \
      %w(
        default.spec.erb
        fedora-17-18.spec.erb
        fedora-19-20.spec.erb
        fedora-21-25-vagrant-plugin.spec.erb
        fedora-21-25.spec.erb
        fedora-26-vagrant-plugin.spec.erb
        fedora-26.spec.erb
        fedora-27-rawhide-vagrant-plugin.spec.erb
        fedora-27-rawhide.spec.erb
        fedora.spec.erb
        opensuse.spec.erb
        pld.spec.erb
      ), Gem2Rpm::Template.list
  end

  def test_list_is_memoized
    assert_same Gem2Rpm::Template.list, Gem2Rpm::Template.list
  end

  def test_find_without_argument
    assert Gem2Rpm::Template.find
  end

  def test_find_with_short_template_name
    assert_match "Provides: rubygem(%{gem_name}) = %{version}",
      Gem2Rpm::Template.find('fedora-19-20').read
  end

  def test_find_with_full_path
    assert_match "foofoo 17 barbar",
      Gem2Rpm::Template.find(
        File.expand_path('templates/fake_files/fedora-release17', File.dirname(__FILE__))
      ).read
  end

  # This fails on Travis, since the template for the distro is not available.
  def test_find_vagrant_template
    assert_match "vagrant",
      Gem2Rpm::Template.find(nil, :gem_file => 'vagrant-').read
  rescue Gem2Rpm::Template::TemplateError
  end

  def test_new
    assert_raises(Gem2Rpm::Template::TemplateError) { Gem2Rpm::Template.new 'some_filename' }
    assert Gem2Rpm::Template.new File.join(Gem2Rpm::Template.default_location, 'default.spec.erb')
  end

  def test_read
    assert Gem2Rpm::Template.new(File.join(Gem2Rpm::Template.default_location, 'default.spec.erb')).read.size == 1886
  end

  def test_read_is_memoized
    template = Gem2Rpm::Template.new(
      File.join(Gem2Rpm::Template.default_location, 'default.spec.erb')
    )

    assert_same template.read, template.read
  end
end
